defmodule Akd.Hook do
  @moduledoc """
  This module defines a hook struct and a behavior hook modules must follow
  """

  alias Akd.{Deployment, Destination, Hook, SecureConnection}

  @enforce_keys ~w(runat)a
  @optional_keys ~w(commands cleanup opts env)a

  defstruct @enforce_keys ++ @optional_keys

  @typedoc ~s(Generic type for a Hook with all enforced keys)
  @type t :: %__MODULE__{
    commands: String.t | nil,
    runat: Destination.t,
    cleanup: String.t | nil,
    opts: list() | nil,
    env: list(tuple()) | nil,
  }

  @callback get_hook(deployment :: Deployment.t, opts :: list) :: Hook.t

  @doc ~s()
  @spec exec(Hook.t) :: {:ok, String.t} | {:error, String.t}
  def exec(hook)
  def exec(%Hook{runat: %Destination{server: :local}} = hook) do
    with {output, 0} <- System.cmd("sh", ["-c" , hook.commands], cd: hook.runat.path) do
      {:ok, output}
    else
      {error, 1} -> {:error, error}
    end
  end
  def exec(%Hook{commands: commands, runat: runat}) do
    SecureConnection.securecmd(runat, commands)
  end
end


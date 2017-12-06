defmodule Akd.Hook do
  @moduledoc """
  This module defines a hook struct and a behavior hook modules must follow
  """

  alias Akd.{Destination, Deployment, Hook, SecureConnection}

  @enforce_keys ~w(commands exec_dest)a
  @optional_keys ~w(opts)a

  defstruct @enforce_keys ++ @optional_keys

  @typedoc ~s(Generic type for a Hook with all enforced keys)
  @type t :: %__MODULE__{
    commands: String.t | :noop,
    exec_dest: Akd.Destination.t,
    opts: list | nil
  }

  @callback commands(deployment :: Deployment.t, opts :: list) :: String.t

  @doc ~s()
  @spec exec(Hook.t) :: {:ok, String.t} | {:error, String.t}
  def exec(hook)
  def exec(%Hook{exec_dest: %Destination{sshserver: :local}} = hook) do
    with {output, 0} <- System.cmd("sh", ["-c" , hook.commands], cd: hook.exec_dest.path) do
      {:ok, output}
    else
      {error, 1} -> {:error, error}
    end
  end
  def exec(%Hook{commands: commands, exec_dest: exec_dest}) do
    SecureConnection.securecmd(exec_dest, commands)
  end
end


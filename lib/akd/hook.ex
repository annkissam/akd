defmodule Akd.Hook do
  @moduledoc """
  This module defines a hook struct and a behavior hook modules must follow
  """

  alias Akd.{Deployment, Destination, SecureConnection}

  @enforce_keys ~w(runat)a
  @optional_keys ~w(commands cleanup env rollback ignore_failure)a

  defstruct @enforce_keys ++ @optional_keys

  @typedoc ~s(Generic type for a Hook with all enforced keys)
  @type t :: %__MODULE__{
    cleanup: String.t | nil,
    commands: String.t | nil,
    env: list(tuple()) | nil,
    rollback: String.t | nil,
    runat: Destination.t,
    ignore_failure: true | false | nil,
  }

  @callback get_hook(deployment :: Deployment.t, opts :: list) :: __MODULE__.t

  defmacro __using__(_) do
    quote do
      @behviour unquote(__MODULE__)

      @spec get_hook(Akd.Deployment.t, list) :: Akd.Hook.t
      def get_hook(_, _), do: raise "`get_hook/2` not defined for #{__MODULE__}"

      defoverridable [get_hook: 2]
    end
  end

  @doc ~s()
  @spec exec(__MODULE__.t) :: {:ok, String.t} | {:error, String.t}
  def exec(hook)
  def exec(%__MODULE__{runat: %Destination{server: :local}} = hook) do
    case System.cmd("sh", ["-c" , hook.commands], cd: hook.runat.path, into: IO.stream(:stdio, :line)) do
      {error, 1} -> {:error, error}
      {output, _} -> {:ok, output}
    end
  end
  def exec(%__MODULE__{commands: commands, runat: runat}) do
    SecureConnection.securecmd(runat, commands)
  end

  def cleanup(hook)
  def cleanup(%__MODULE__{cleanup: nil}), do: {:ok, nil}
  def cleanup(%__MODULE__{runat: %Destination{server: :local}} = hook) do
    with {output, 0} <- System.cmd("sh", ["-c" , hook.cleanup], cd: hook.runat.path, into: IO.stream(:stdio, :line)) do
      {:ok, output}
    else
      {error, 1} -> {:error, error}
    end
  end
  def cleanup(%__MODULE__{cleanup: commands, runat: runat}) do
    SecureConnection.securecmd(runat, commands)
  end

  def commands_with_env(%__MODULE__{commands: commands, env: nil}), do: commands
  def commands_with_env(%__MODULE__{commands: commands, env: _}), do: commands

  def rollback(%__MODULE__{rollback: nil}), do: :ok
  # def rollback(%__MODULE__{rollback: cmd}), do call_cmd(hook, cmd)
end


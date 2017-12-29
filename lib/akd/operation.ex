defmodule Akd.Operation do
  @moduledoc """
  This module represents an `Operation` struct which contains metadata about
  a command/operation that can be run on a destination.

  Please refer to `Nomenclature` for more information about the terms used.

  The meta data involves:

  * cmd - Commands that are ran when an `Akd.Operation.t` struct is run.
  * cmd_envs - ENV variables that the command is run with. Represented by a list
              of two element (strings) tuples.
              Example: [{"SOME_ENV", "1"}, {"OTHER_ENV", "2"}]
  * destination - `Akd.Destination.t` where an operation's commands are executed.

  This struct is mainly used by native hooks in `Akd`, but it can be leveraged
  to write custom hooks.
  """

  alias Akd.Destination

  @enforce_keys ~w(destination)a
  @optional_keys [cmd_envs: [], cmd: ""]

  defstruct @enforce_keys ++ @optional_keys

  @typedoc ~s(Type representing a Command to be run)
  @type cmd :: String.t | :exit

  @typedoc ~s(Type representind a command specific environment)
  @type cmd_env :: {String.t, String.t}

  @typedoc ~s(Generic type for an Operation struct)
  @type t :: %__MODULE__{
    cmd_envs: [cmd_env],
    cmd: cmd,
    destination: Destination.t
  }

  @doc """
  Runs a given `Operation.t` command on it's destination.
  If the destination is local, it just runs it on the local machine.
  If the destination is remote, it runs it through SSH.

  ## Exmaples:
  When the destination is local

      iex> envs = [{"AKDNAME", "dragonborn"}]
      iex> dest = %Akd.Destination{}
      iex> cmd = "echo $AKDNAME"
      iex> op = %Akd.Operation{cmd_envs: envs, cmd: cmd, destination: dest}
      iex> run(op)
      {:ok, "dragonborn"}

  When the destination is remote

      iex> envs = [{"AKDNAME", "dragonborn"}]
      iex> dest = %Akd.Destination{user: "dovahkiin", host: "skyrim"}
      iex> cmd = "echo $AKDNAME"
      iex> op = %Akd.Operation{cmd_envs: envs, cmd: cmd, destination: dest}
      iex> run(op)
      {:ok, "dragonborn"}

  """
  @spec run(__MODULE__.t) :: {:ok, term} | {:error, term}
  def run(operation)
  def run(%__MODULE__{destination: %Destination{host: :local}} = operation) do
    IO.inspect environmentalize_cmd(operation)
    case System.cmd("sh", ["-c" , operation.cmd],
            env: operation.cmd_envs,
            cd: operation.destination.path,
            into: IO.stream(:stdio, :line)) do
      {error, 1} -> {:error, error}
      {output, _} -> {:ok, output}
    end
  end
  def run(op) do
    Akd.SecureConnection.securecmd(op.destination, environmentalize_cmd(op))
  end


  @doc """
  Takes an Operation and returns a string of commands with `cmd_envs` preprended
  to the `cmd` script.

  ## Examples:
  When a non-empty list of environments are given:

      iex> envs = [{"NAME", "dragonborn"}, {"NOK", "dovahkiin"}]
      iex> dest = %Akd.Destination{}
      iex> op = %Akd.Operation{cmd_envs: envs, cmd: "thuum", destination: dest}
      iex> Akd.Operation.environmentalize_cmd(op)
      NAME=dragonborn NOK=dovahkiin thuum

  When an empty list of environments are given:

      iex> dest = %Akd.Destination{}
      iex> op = %Akd.Operation{cmd_envs: [], cmd: "thuum", destination: dest}
      iex> Akd.Operation.environmentalize_cmd(op)
      thuum

  """
  @spec environmentalize_cmd(__MODULE__.t) :: String.t
  def environmentalize_cmd(%__MODULE__{cmd_envs: cmd_envs, cmd: cmd}) do
    envs = cmd_envs
      |> Enum.map(fn {name, value} -> "#{name}=#{value}" end)
      |> Enum.join(" ")

    cmd
    |> String.split("\n")
    |> Enum.map(& envs <> " " <> &1)
    |> Enum.join("\n ")
  end
end

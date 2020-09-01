defmodule Akd.SecureConnection do
  require Logger

  @moduledoc """
  This module defines helper functions that are used by `Akd` to execute
  a set of commands through the Secure channel, examples: ssh and scp
  """

  @doc """
  Takes a destination and commands and runs those commands on that destination.

  ## Examples

      iex> Akd.SecureConnection.securecmd(Akd.Destination.local(), "echo hi")
      {:error, %IO.Stream{device: :standard_io, line_or_bytes: :line, raw: false}}
  """
  def securecmd(dest, cmds) do
    cmds = "cd #{dest.path}\n" <> cmds
    ssh(dest.user, dest.host, cmds, true)
  end

  @doc """
  Takes a user, host and a string of operations and runs those operations
  on that host

  ## Examples

      iex> Akd.SecureConnection.ssh(:current, :local, "echo hi")
      {:error, ""}

      iex> Akd.SecureConnection.ssh(:current, :local, "echo hi", true)
      {:error, %IO.Stream{device: :standard_io, line_or_bytes: :line, raw: false}}
  """
  def ssh(user, scoped_ip, operations, stdio \\ false) do
    Logger.info("ssh #{user}@#{scoped_ip}")
    Logger.info("running: #{operations}")

    opts = (stdio && [into: IO.stream(:stdio, :line)]) || []

    case System.cmd("ssh", ["#{user}@#{scoped_ip}", operations], opts) do
      {output, 0} -> {:ok, output}
      {error, _} -> {:error, error}
    end
  end

  @doc """
  Takes a source and a destination and copies src to destination

  ## Examples

      iex> src = "user@host:~/path"
      iex> dest = "user2@host2:~/path2"
      iex> Akd.SecureConnection.scp(src, dest)
      {:error, %IO.Stream{device: :standard_io, line_or_bytes: :line, raw: false}}

      iex> src = "user@host:~/path"
      iex> dest = "user2@host2:~/path2"
      iex> Akd.SecureConnection.scp(src, dest, ["-p a"])
      {:error, %IO.Stream{device: :standard_io, line_or_bytes: :line, raw: false}}
  """
  def scp(src, dest, opts \\ []) do
    Logger.info("scp #{src} #{dest}")

    case System.cmd("scp", opts ++ [src, dest], into: IO.stream(:stdio, :line)) do
      {output, 0} -> {:ok, output}
      {error, _} -> {:error, error}
    end
  end
end

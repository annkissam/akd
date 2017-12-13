defmodule Akd.SecureConnection do
  def securecmd(dest, cmds) do
    cmds = "cd #{dest.path}\n" <> cmds
    ssh(dest.user, dest.server, cmds, true)
  end

  def ssh(user, scoped_ip, operations, stdio \\ false) do
    IO.inspect "ssh #{user}@#{scoped_ip}"
    IO.inspect "running: #{operations}"

    opts = stdio && [into: IO.stream(:stdio, :line)] || []

    case System.cmd("ssh", ["#{user}@#{scoped_ip}", operations], opts) do
      {output, 0} -> {:ok, output}
      {error, 1} -> {:error, error}
    end
  end

  def scp(src, dest, opts \\ []) do
    IO.inspect "scp #{src} #{dest}"

    case System.cmd("scp", opts ++ [src, dest], [into: IO.stream(:stdio, :line)])
      do
      {output, 0} -> {:ok, output}
      {error, 1} -> {:error, error}
    end
  end
end

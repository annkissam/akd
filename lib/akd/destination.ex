defmodule Akd.Destination do
  alias Akd.Destination

  @enforce_keys [:sshuser, :sshserver, :path]

  defstruct @enforce_keys

  @typedoc ~s(Generic type for Destination with all enforced keys)
  @type t :: %__MODULE__{
    sshuser: String.t | :local,
    sshserver: String.t |:local,
    path: String.t
  }

  @doc ~s()
  @spec to_s(Destination.t) :: String.t
  def to_s(dest)
  def to_s(%Destination{sshuser: :local, sshserver: :local, path: path}), do: path
  def to_s(%Destination{sshuser: user, sshserver: ip, path: path}) do
    "#{user}@#{ip}:#{path}"
  end
end

defmodule Akd.Destination do
  alias Akd.Destination

  @enforce_keys [:user, :server, :path]

  defstruct @enforce_keys

  @typedoc ~s(Generic type for Destination with all enforced keys)
  @type t :: %__MODULE__{
    user: String.t | :current,
    server: String.t | :local,
    path: String.t
  }

  @doc ~s()
  @spec to_s(Destination.t) :: String.t
  def to_s(dest)
  def to_s(%Destination{user: :current, server: :local, path: path}), do: path
  def to_s(%Destination{user: user, server: ip, path: path}) do
    "#{user}@#{ip}:#{path}"
  end

  @spec parse(String.t) :: Destination.t
  def parse(string) do
    [user, server, path] = Regex.split(~r{@|:}, string)
    %Destination{user: user, server: server, path: path}
  end

  def local() do
    %Destination{user: :current, server: :local, path: "."}
  end
end

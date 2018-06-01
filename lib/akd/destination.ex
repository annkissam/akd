defmodule Akd.Destination do
  @moduledoc """
  This module represents a `Destination` struct which contains metadata about
  a destination/location/host.

  The meta data involves:

  * `user` - Represents the user who will be accessing a host/server.
           Expects a string, defaults to `:current`.
  * `host` - Represents the host/server being accessed.
           Expects a string, defaults to `:local`.
  * `path` - Represents the path on the server being accessed.
           Expects a string, defaults to `.` (current directory).

  Example:
  - Accessing `root@x.x.x.x:/path/to/dir"` would have:
      * `user`: `"root"`
      * `host`: `"x.x.x.x"`
      * `path`: `"/path/to/dir/"`

  This struct is mainly used by native hooks in `Akd`, but it can be leveraged
  to produce custom hooks.
  """

  defstruct [user: :current, host: :local, path: "."]

  @typedoc ~s(A `Akd.Destination.user` can be either a string or `:current`)
  @type user :: String.t | :current

  @typedoc ~s(A `Akd.Destination.host` can be either a string or `:local`)
  @type host :: String.t | :local

  @typedoc ~s(Generic type for Akd.Destination)
  @type t :: %__MODULE__{
    user: user,
    host: host,
    path: String.t
  }

  @doc """
  Takes an `Akd.Destination.t` struct, `dest` and parses it into a readable string.

  ##  Examples
  When `dest` is a local destination:

      iex> params = %{user: :current, host: :local, path: "/path/to/dir"}
      iex> local_destination = struct!(Akd.Destination, params)
      iex> Akd.Destination.to_string(local_destination)
      "/path/to/dir"


  When `dest` remote destination:

      iex> params = %{user: "dragonborn", host: "skyrim", path: "whiterun"}
      iex> local_destination = struct!(Akd.Destination, params)
      iex> Akd.Destination.to_string(local_destination)
      "dragonborn@skyrim:whiterun"

  """
  @spec to_string(__MODULE__.t) :: String.t
  def to_string(dest)
  def to_string(%__MODULE__{user: :current, host: :local, path: path}), do: path
  def to_string(%__MODULE__{user: user, host: ip, path: path}) do
    "#{user}@#{ip}:#{path}"
  end

  @doc """
  Takes a readable string and converts it to an `Akd.Destination.t` struct.
  Expects the string to be in the following format:
    `<user>@<host>:<path>`
  and parses it to:
    `%Akd.Destination{user: <user>, host: <host>, path: <path>}`

  Raises a `MatchError` if the string isn't in the correct format.

  ## Examples
  When a string with the correct format is given:

      iex> Akd.Destination.parse("dragonborn@skyrim:whiterun")
      %Akd.Destination{user: "dragonborn", host: "skyrim", path: "whiterun"}

  When a wrongly formatted string is given:

      iex> Akd.Destination.parse("arrowtotheknee")
      ** (MatchError) no match of right hand side value: ["arrowtotheknee"]

  """
  @spec parse(String.t) :: __MODULE__.t
  def parse(string) do
    [user, host, path] = Regex.split(~r{@|:}, string)
    %__MODULE__{user: user, host: host, path: path}
  end


  @doc """
  Takes a string path and returns a local `Akd.Destination.t` struct which
  corresponds to locahost with the given `path`.

  __Alternatively one can initialize an `Akd.Destination.t` struct with just
  a path, which will return a local Destination struct by default__

  ## Examples
  When a path is given:

      iex> Akd.Destination.local("/fus/ro/dah")
      %Akd.Destination{host: :local, path: "/fus/ro/dah", user: :current}

  """
  @spec local(String.t) :: __MODULE__.t
  def local(path \\ ".") do
    %__MODULE__{user: :current, host: :local, path: path}
  end
end

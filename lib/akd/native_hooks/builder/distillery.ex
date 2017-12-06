defmodule Akd.Builder.Distillery do
  @moduledoc """
  This module connects to a given remote server through ssh and builds a release
  on that server.
  """

  @behavior Akd.Hook

  @doc """
  Callback implementation for `commands`.
  """
  def commands(d, _opts), do: "MIX_ENV=#{d.app_env} mix release --env=#{d.app_env}"
end

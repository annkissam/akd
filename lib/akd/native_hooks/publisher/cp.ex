defmodule Akd.Publisher.Cp do
  @moduledoc """
  This module connects to a given remote server through ssh and publishes a
  release on that server.
  """

  use Akd.Hook

  alias Akd.Deployment

  def commands(%Deployment{}) do
    raise "Not implemented"
  end
end

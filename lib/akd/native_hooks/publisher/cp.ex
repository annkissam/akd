defmodule Akd.Publisher.CP do
  @moduledoc """
  This module connects to a given remote server through ssh and publishes a
  release on that server.
  """

  @behavior Akd.Hook

  alias Akd.{Deployment, Destination}

  def commands(%Deployment{publishto: dest, deployable: deployable}, opts \\ []) do
    "cp -r #{deployable.path} #{dest.path}"
  end
end

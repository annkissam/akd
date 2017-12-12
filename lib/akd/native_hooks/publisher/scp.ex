defmodule Akd.Publisher.Scp do
  @moduledoc """
  This module connects to a given remote server through ssh and publishes a
  release on that server.
  """

  @behavior Akd.Hook

  alias Akd.{Deployment, Destination}

  def commands(%Deployment{publishto: dest, deployable: deployable}, opts \\ []) do
    "scp -r #{Destination.to_s(deployable)} #{Destination.to_s(dest)}"
  end
end

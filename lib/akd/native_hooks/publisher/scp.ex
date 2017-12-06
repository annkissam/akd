defmodule Akd.Publisher.SCP do
  @moduledoc """
  This module connects to a given remote server through ssh and publishes a
  release on that server.
  """

  @behavior Akd.Hook

  alias Akd.{Deployment, Destination}

  def commands(%Deployment{publish_env: dest, release: release}, opts \\ []) do
    "scp -r #{Destination.to_s(release)} #{Destination.to_s(dest)}"
  end
end

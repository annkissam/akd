defmodule Akd.Fetcher.SCP do
  @moduledoc """
  Fetches source code using SCP. This is a basic fetcher that just copies
  the code that the task is ran from to the build env
  """

  @behavior Akd.Hook

  alias Akd.{Deployment, Destination}

  def commands(%Deployment{buildat: buildat}, _opts) do
    """
    scp -r . #{Destination.to_s(buildat)}
    """
  end
end

defmodule Akd.Fetcher.SCP do
  @moduledoc """
  Fetches source code using SCP. This is a basic fetcher that just copies
  the code that the task is ran from to the build env
  """

  @behavior Akd.Hook

  alias Akd.{Deployment, Destination}

  def commands(%Deployment{build_env: build_env}, _opts) do
    "scp -r . #{Destination.to_s(build_env)}"
  end
end

defmodule Akd.Fetcher.Git do
  @moduledoc """
  Fetches source code using Git. This is a basic fetcher that just copies
  the code that the task is ran from to the build env
  """

  @behaviour Akd.Hook

  alias Akd.{Deployment, Destination}

  def get_hook(%Deployment{}, opts) do
    branch = opts[:branch] || "master"
    src = opts[:src] || :local
  end
end

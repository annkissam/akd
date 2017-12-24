defmodule Akd.Fetcher.Git do
  @moduledoc """
  Fetches source code using Git. This is a basic fetcher that just copies
  the code that the task is ran from to the build env
  """

  use Akd.Hook

  alias Akd.{Deployment, DestinationResolver, Hook}

  def get_hooks(%Deployment{} = deployment, opts) do
    branch = opts[:branch] || "master"
    src = opts[:src]

    runat = opts[:runat] || DestinationResolver.resolve(:build, deployment)

    [%Hook{commands: commands(branch, src), runat: runat, env: opts[:env]}]
  end

  defp commands(branch, nil) do
    """
    git checkout #{branch}
    git pull
    """
  end
  defp commands(branch, url) when is_binary(url) do
    """
    git clone #{url} .
    git checkout #{branch}
    """
  end
end

defmodule Akd.Fetcher.Git do
  @moduledoc """
  TODO: Improve Docs

  Fetches source code using Git. This is a basic fetcher that just copies
  the code that the task is ran from to the build env
  """

  use Akd.Hook

  def get_hooks(deployment, opts \\ []) do
    branch = Keyword.get(opts, :branch, "master")
    src = Keyword.get(opts, :src)
    destination = Akd.DestinationResolver.resolve(:build, deployment)

    [fetch_hook(src, branch, destination, opts)]
  end

  defp fetch_hook(src, branch, destination, opts) do
    form_hook opts do
      main "git clone #{src} .", destination
      main "git checkout #{branch}", destination
      main "git pull", destination

      ensure "rm -rf ./*", destination
      ensure "rm -rf ./.*", destination
    end
  end
end

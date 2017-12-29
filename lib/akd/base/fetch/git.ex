defmodule Akd.Fetch.Git do
  @moduledoc """
  A native Hook module that comes shipped with Akd.

  This module uses `Akd.Hook`.

  Provides a set of operations that fetch source code using `git` to a destination,
  check out a given branch (defaults to `master`) and pull the latest version
  of the branch on the destination.

  Ensures to cleanup and empty the desination directory. (Doesn't run this by
  default)

  Doesn't have any Rollback operations.

  # Defaults:

  * `run_ensure`: `false`
  * `ignore_failure`: `false`
  * `branch`: `master`

  """

  use Akd.Hook

  @default_opts [run_ensure: false, ignore_failure: false, branch: "master"]

  def get_hooks(deployment, opts \\ []) do
    opts = uniq_merge(opts, @default_opts)
    branch = Keyword.get(opts, :branch)
    src = Keyword.get(opts, :src)
    destination = Akd.DestinationResolver.resolve(:build, deployment)

    [fetch_hook(src, branch, destination, opts)]
  end

  defp fetch_hook(src, branch, destination, opts) do
    form_hook opts do
      main "git clone #{src} .", destination
      main "git fetch", destination
      main "git checkout #{branch}", destination
      main "git pull", destination

      ensure "rm -rf ./*", destination
      ensure "rm -rf ./.*", destination
    end
  end

  defp uniq_merge(keyword1, keyword2) do
    keyword1
    |> Keyword.merge(keyword2)
    |> Keyword.new()
  end
end

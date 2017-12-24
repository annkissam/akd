defmodule Akd.Fetch.Scp do
  @moduledoc """
  Fetches source code using scp. This is a basic fetcher that just copies
  the code that the task is ran from to the build env
  """

  use Akd.Hook

  def get_hooks(deployment, opts) do
    src = Keyword.get(opts, :src, ".")
    [init_hook(src, deployment, opts)]
  end

  defp init_hook(src, deployment, opts) when is_binary(src) do
    dest = deployment.build_at |> Akd.Destination.to_string()
    excludes = Keyword.get(opts, :exclude, ~w(_build .git deps))

    form_hook opts do
      main rsync_cmd(src, dest, excludes), Akd.Destination.local()

      ensure "rm -rf #{dest}", deployment.build_at
    end
  end
  defp init_hook(src, deployment, opts) do
    dest = deployment.build_at |> Akd.Destination.to_string()
    src = Akd.Destination.to_string(src)
    excludes = Keyword.get(opts, :exclude, ~w(_build .git deps))

    form_hook opts do
      main rsync_cmd(src, dest, excludes), Akd.Destination.local()

      ensure "rm -rf #{dest}", deployment.build_at
    end
  end

  defp rsync_cmd(src, dest, excludes) do
    Enum.reduce(excludes, "rsync -krav -e ssh", fn(ex, cmd) ->
      cmd <> " --exclude=\"#{ex}\""
    end) <> " #{src} #{dest}"
  end
end

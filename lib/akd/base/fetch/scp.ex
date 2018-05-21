defmodule Akd.Fetch.Scp do
  @moduledoc """
  A native Hook module that comes shipped with Akd.

  This module uses `Akd.Hook`.

  Provides a set of operations that fetch source code using `scp` from a given
  source to a destination.

  Ensures to cleanup and empty the desination directory. (Doesn't run this by
  default)

  Doesn't have any Rollback operations.

  # Options:

  * `run_ensure`: `boolean`. Specifies whether to a run a command or not.
  * `ignore_failure`: `boolean`. Specifies whether to continue if this hook fails.
  * `src`: `string`. Source of the code from where to scp the data.
  * `exclude`: `list`. Scp all folders except the ones given in exclude.

  # Defaults:

  * `run_ensure`: `false`
  * `ignore_failure`: `false`
  * `src`: Current working directory, `.`
  * `exclude`: `["_build", ".git", "deps", ".gitignore"]`

  """

  use Akd.Hook

  @default_opts [run_ensure: true, ignore_failure: false, src: "."]

  @doc """
  Callback implementation for `get_hooks/2`.

  This function returns a list of operations that can be used to fetch source
  code using `scp` from a given source.

  ## Examples

      iex> deployment = %Akd.Deployment{mix_env: "prod",
      ...> build_at: Akd.Destination.local(),
      ...> publish_to: Akd.Destination.local(),
      ...> name: "name",
      ...> vsn: "0.1.1"}
      iex> Akd.Fetch.Scp.get_hooks(deployment, [exclude: []])
      [%Akd.Hook{ensure: [%Akd.Operation{cmd: "rm -rf ./*", cmd_envs: [],
            destination: %Akd.Destination{host: :local, path: ".",
             user: :current}}], ignore_failure: false,
          main: [%Akd.Operation{cmd: "rsync -krav -e ssh . .", cmd_envs: [],
            destination: %Akd.Destination{host: :local, path: ".",
             user: :current}}], rollback: [], run_ensure: true}]
      iex> Akd.Fetch.Scp.get_hooks(deployment, [src: Akd.Destination.local()])
      [%Akd.Hook{ensure: [%Akd.Operation{cmd: "rm -rf ./*", cmd_envs: [],
           destination: %Akd.Destination{host: :local, path: ".",
            user: :current}}], ignore_failure: false,
           main: [%Akd.Operation{cmd: "rsync -krav -e ssh --exclude=\\"_build\\" --exclude=\\".git\\" --exclude=\\"deps\\" . .",
           cmd_envs: [],
           destination: %Akd.Destination{host: :local, path: ".",
            user: :current}}], rollback: [], run_ensure: true}]

  """
  @spec get_hooks(Akd.Deployment.t, Keyword.t) :: list(Akd.Hook.t)
  def get_hooks(deployment, opts) do
    opts = uniq_merge(opts, @default_opts)
    src = Keyword.get(opts, :src)

    [fetch_hook(src, deployment, opts)]
  end

  # This function takes a source, a destination and options and
  # returns an Akd.Hook.t struct using the form_hook DSL.
  defp fetch_hook(src, deployment, opts) when is_binary(src) do
    destination = Akd.DestinationResolver.resolve(:build, deployment)
    dest = Akd.Destination.to_string(destination)
    excludes = Keyword.get(opts, :exclude, ~w(_build .git deps))

    form_hook opts do
      main rsync_cmd(src, dest, excludes), Akd.Destination.local()

      ensure "rm -rf ./*", destination
    end
  end
  defp fetch_hook(%Akd.Destination{} = src, deployment, opts) do
    src = Akd.Destination.to_string(src)
    fetch_hook(src, deployment, opts)
  end

  # This function returns an rsync command with all the
  # `exclude` switches added to it.
  defp rsync_cmd(src, dest, excludes) do
    Enum.reduce(excludes, "rsync -krav -e ssh", fn(ex, cmd) ->
      cmd <> " --exclude=\"#{ex}\""
    end) <> " #{src} #{dest}"
  end

  # This function takes two keyword lists and merges them keeping the keys
  # unique. If there are multiple values for a key, it takes the value from
  # the first value of keyword1 corresponding to that key.
  defp uniq_merge(keyword1, keyword2) do
    keyword2
    |> Keyword.merge(keyword1)
    |> Keyword.new()
  end
end

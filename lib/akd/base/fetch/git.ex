defmodule Akd.Fetch.Git do
  @moduledoc """
  A native Hook module that comes shipped with Akd.

  This module uses `Akd.Hook`.

  Provides a set of operations that fetch source code using `git` to a destination,
  checks out a given branch (defaults to `master`) and pulls the latest version
  of the branch on the destination.

  Ensures to clean up and empty the desination directory. (Doesn't run this by
  default)

  Doesn't have any Rollback operations.

  # Options:

  * `run_ensure`: `boolean`. Specifies whether to a run a command or not.
  * `ignore_failure`: `boolean`. Specifies whether to continue if this hook fails.
  * `src`: `string`. Source/Repo from where to clone the project. This is a required
      option while using this hook.
  * `branch`: `string`. Branch of the git repo that is being deployed.

  # Defaults:

  * `run_ensure`: `false`
  * `ignore_failure`: `false`
  * `branch`: `master`

  """

  use Akd.Hook

  @default_opts [run_ensure: false, ignore_failure: false, branch: "master"]

  @errmsg %{no_src: "No `src` given to `Akd.Fetch.Git`. Expected a git repo."}

  @doc """
  Callback implementation for `get_hooks/2`.

  This function returns a list of operations that can be used to fetch a source
  code using `git` from a branch.

  ## Examples
  When no `src` is given with `opts`:

      iex> deployment = %Akd.Deployment{mix_env: "prod",
      ...> build_at: Akd.Destination.local("."),
      ...> publish_to: Akd.Destination.local("."),
      ...> name: "name",
      ...> vsn: "0.1.1"}
      iex> Akd.Fetch.Git.get_hooks(deployment, [])
      ** (RuntimeError) No `src` given to `Akd.Fetch.Git`. Expected a git repo.

  When a `src` is given:

      iex> deployment = %Akd.Deployment{mix_env: "prod",
      ...> build_at: Akd.Destination.local("."),
      ...> publish_to: Akd.Destination.local("."),
      ...> name: "name",
      ...> vsn: "0.1.1"}
      iex> Akd.Fetch.Git.get_hooks(deployment, [src: "url"])
      [%Akd.Hook{ensure: [%Akd.Operation{cmd: "rm -rf ./*", cmd_envs: [],
        destination: %Akd.Destination{host: :local, path: ".",
         user: :current}},
        %Akd.Operation{cmd: "rm -rf ./.*", cmd_envs: [],
            destination: %Akd.Destination{host: :local, path: ".",
        user: :current}}], ignore_failure: false,
              main: [%Akd.Operation{cmd: "git status; if [[ $? != 0 ]]; then git clone url .; fi", cmd_envs: [],
         destination: %Akd.Destination{host: :local, path: ".",
             user: :current}},
        %Akd.Operation{cmd: "git fetch", cmd_envs: [],
             destination: %Akd.Destination{host: :local, path: ".",
              user: :current}},
        %Akd.Operation{cmd: "git checkout master", cmd_envs: [],
             destination: %Akd.Destination{host: :local, path: ".",
             user: :current}},
        %Akd.Operation{cmd: "git pull", cmd_envs: [],
             destination: %Akd.Destination{host: :local, path: ".",
             user: :current}}], rollback: [], run_ensure: false}]

  """
  @spec get_hooks(Akd.Deployment.t, Keyword.t) :: list(Akd.Hook.t)
  def get_hooks(deployment, opts \\ []) do
    opts = uniq_merge(opts, @default_opts)
    branch = Keyword.get(opts, :branch)
    src = Keyword.get(opts, :src)
    destination = Akd.DestinationResolver.resolve(:build, deployment)

    [fetch_hook(src, branch, destination, opts)]
  end

  # This function takes a source, branch, destination and options and
  # returns an Akd.Hook.t struct using the form_hook DSL.
  defp fetch_hook(nil, _, _, _), do: raise @errmsg[:no_src]
  defp fetch_hook(src, branch, destination, opts) do
    form_hook opts do
      main "git status; if [[ $? != 0 ]]; then git clone #{src} .; fi", destination
      main "git fetch", destination
      main "git checkout #{branch}", destination
      main "git pull", destination

      ensure "rm -rf ./*", destination
      ensure "rm -rf ./.*", destination
    end
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

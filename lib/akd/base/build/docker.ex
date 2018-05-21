defmodule Akd.Build.Docker do
  @moduledoc """
  A native Hook module that comes shipped with Akd.

  This module uses `Akd.Hook`.

  Provides a set of operations that build an elixir app in a Docker container
  using a specified `Dockerfile` at a deployment's `build_at` destination.

  This hook assumes that there is `docker 17.x` installed on the `build_at`
  destination.

  This hook also assumes that the given `Dockerfile` has all the operations setup.

  Ensures to cleanup and remove the Docker images/containers created by this build.
  `run_ensure` is set to `false` on default. So, by default it doesn't remove
  the containers. This is to speed up the next build. If you wish to remove
  these containers, make sure to pass `run_ensure` as `true`.

  Doesn't have any Rollback operations.

  # Options:

  * `run_ensure`: `boolean`. Specifies whether to a run a command or not.
  * `ignore_failure`: `boolean`. Specifies whether to continue if this hook fails.
  * `cmd_env`: `list` of `tuples`. Specifies the environments to provide while
        building the distillery release.

  # Defaults:

  * `run_ensure`: `false`
  * `ignore_failure`: `false`

  """

  use Akd.Hook

  @default_opts [run_ensure: false, ignore_failure: false, file: "Dockerfile",
                 path: "."]

  @doc """
  Callback implementation for `get_hooks/2`.

  This function returns a list of operations that can be used to build a release
  using distillery on the `build_at` destination of a deployment.

  ## Examples

      iex> deployment = %Akd.Deployment{mix_env: "prod",
      ...> build_at: Akd.Destination.local("."),
      ...> publish_to: Akd.Destination.local("."),
      ...> name: "name",
      ...> vsn: "0.1.1"}
      iex> Akd.Build.Docker.get_hooks(deployment, [])
      [%Akd.Hook{ensure: [%Akd.Operation{cmd: "docker rm $(docker ps -a -q)",
        cmd_envs: [],
        destination: %Akd.Destination{host: :local, path: ".",
         user: :current}}], ignore_failure: false,
      main: [%Akd.Operation{cmd: "docker build -f Dockerfile -t name:0.1.1 .",
        cmd_envs: [],
        destination: %Akd.Destination{host: :local, path: ".",
         user: :current}}], rollback: [], run_ensure: false}]

  """
  @spec get_hooks(Akd.Deployment.t, Keyword.t) :: list(Akd.Hook.t)
  def get_hooks(deployment, opts) do
    [build_hook(deployment, uniq_merge(opts, @default_opts))]
  end

  # This function takes a deployment and options and returns an Akd.Hook.t
  # struct using FormHook DSL
  defp build_hook(deployment, opts) do
    destination = Akd.DestinationResolver.resolve(:build, deployment)
    path = Keyword.get(opts, :path)
    file = Keyword.get(opts, :file)
    tag = Keyword.get(opts, :tag, deployment.name <> ":" <> deployment.vsn)

    form_hook opts do
      main "docker build -f #{file} -t #{tag} #{path}", destination

      ensure "docker rm $(docker ps -a -q)", destination
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

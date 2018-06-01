defmodule Akd.Build.Distillery do
  @moduledoc """
  A native Hook module that comes shipped with Akd.

  This module uses `Akd.Hook`.

  Provides a set of operations that build a distillery release for a given app
  at a deployment's `build_at` destination. This hook assumes that a distillery
  rel config file, `rel/config.exs` is already present or initialized by either
  a previously executed hook or manually.

  Ensures to cleanup and empty the releases created by this build.

  Doesn't have any Rollback operations.

  # Options:

  * `run_ensure`: `boolean`. Specifies whether to a run a command or not.
  * `ignore_failure`: `boolean`. Specifies whether to continue if this hook fails.
  * `cmd_envs`: `list` of `tuples`. Specifies the environments to provide while
        building the distillery release.

  # Defaults:

  * `run_ensure`: `true`
  * `ignore_failure`: `false`

  """

  use Akd.Hook

  @default_opts [run_ensure: true, ignore_failure: false]

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
      iex> Akd.Build.Distillery.get_hooks(deployment, [])
      [%Akd.Hook{ensure: [%Akd.Operation{cmd: "rm -rf ./_build/prod/rel",
            cmd_envs: [],
            destination: %Akd.Destination{host: :local, path: ".",
             user: :current}}], ignore_failure: false,
          main: [%Akd.Operation{cmd: "mix deps.get \\n mix compile \\n mix release --env=prod",
            cmd_envs: [{"MIX_ENV", "prod"}],
            destination: %Akd.Destination{host: :local, path: ".",
             user: :current}}], rollback: [], run_ensure: true}]

  """
  @spec get_hooks(Akd.Deployment.t, Keyword.t) :: list(Akd.Hook.t)
  def get_hooks(deployment, opts) do
    [build_hook(deployment, uniq_merge(opts, @default_opts))]
  end

  # This function takes a deployment and options and returns an Akd.Hook.t
  # struct using FormHook DSL
  defp build_hook(deployment, opts) do
    destination = Akd.DestinationResolver.resolve(:build, deployment)
    mix_env = deployment.mix_env
    distillery_env = Keyword.get(opts, :distillery_env, mix_env)
    cmd_envs = Keyword.get(opts, :cmd_envs, [])
    cmd_envs = [{"MIX_ENV", mix_env} | cmd_envs]

    form_hook opts do
      main "mix deps.get \n mix compile \n mix release --env=#{distillery_env}",
        destination, cmd_envs: cmd_envs

      ensure "rm -rf ./_build/prod/rel", destination
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

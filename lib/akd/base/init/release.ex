defmodule Akd.Init.Release do
  @moduledoc """
  A native Hook module that comes shipped with Akd.

  This module uses `Akd.Hook`.

  Provides a set of operations that run distillery's `release.init` task with
  a given template (optional). These commands are ran on the `build_at`
  destination of a deployment.

  Ensures to cleanup and empty the rel/ directory.

  Doesn't have any Rollback operations.

  # Options:

  * `run_ensure`: `boolean`. Specifies whether to a run a command or not.
  * `ignore_failure`: `boolean`. Specifies whether to continue if this hook fails.
  * `cmd_envs`: `list` of `tuples`. Specifies the environments to provide while
        initializing the distillery release.

  # Defaults:

  * `run_ensure`: `true`
  * `ignore_failure`: `false`
  """

  use Akd.Hook

  @default_opts [run_ensure: true, ignore_failure: false]

  @doc """
  Callback implementation for `get_hooks/2`.

  This function returns a list of operations that can be used to init a release
  using distillery on the `build_at` destination of a deployment.

  ## Examples

      iex> deployment = %Akd.Deployment{mix_env: "prod",
      ...> build_at: Akd.Destination.local("."),
      ...> publish_to: Akd.Destination.local("."),
      ...> name: "name",
      ...> vsn: "0.1.1"}
      iex> Akd.Init.Release.get_hooks(deployment, [])
      [%Akd.Hook{ensure: [%Akd.Operation{cmd: "rm -rf _build/prod",
            cmd_envs: [],
            destination: %Akd.Destination{host: :local, path: ".",
            user: :current}}], ignore_failure: false,
          main: [%Akd.Operation{cmd: "mix deps.get \\n mix compile",
            cmd_envs: [{"MIX_ENV", "prod"}],
            destination: %Akd.Destination{host: :local, path: ".",
             user: :current}},
           %Akd.Operation{cmd: "mix release.init",
          cmd_envs: [{"MIX_ENV", "prod"}],
          destination: %Akd.Destination{host: :local, path: ".",
               user: :current}}], rollback: [], run_ensure: true}]

  """
  @spec get_hooks(Akd.Deployment.t(), Keyword.t()) :: list(Akd.Hook.t())
  def get_hooks(deployment, opts \\ []) do
    opts = uniq_merge(opts, @default_opts)

    destination = Akd.DestinationResolver.resolve(:build, deployment)

    [init_hook(destination, deployment.mix_env, opts)]
  end

  # This function takes a destination, a mix_env, switches and options
  # and returns an Akd.Hook.t struct using form_hook DSL.
  defp init_hook(destination, mix_env, opts) do
    cmd_envs = Keyword.get(opts, :cmd_envs, [])
    cmd_envs = [{"MIX_ENV", mix_env} | cmd_envs]

    form_hook opts do
      main(setup(), destination, cmd_envs: cmd_envs)
      main(rel_init(), destination, cmd_envs: cmd_envs)

      ensure("rm -rf _build/prod", destination)
    end
  end

  # This function accumulates all the switches of release.init command
  # and forms a new command.
  # This currently supports only template
  defp rel_init(), do: "mix release.init"

  # These commands are to be ran before calling release init
  defp setup(), do: "mix deps.get \n mix compile"

  # This function takes two keyword lists and merges them keeping the keys
  # unique. If there are multiple values for a key, it takes the value from
  # the first value of keyword1 corresponding to that key.
  defp uniq_merge(keyword1, keyword2) do
    keyword2
    |> Keyword.merge(keyword1)
    |> Keyword.new()
  end
end

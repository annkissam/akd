defmodule Akd.Start.Distillery do
  @moduledoc """
  A native Hook module that comes shipped with Akd.

  This module uses `Akd.Hook`.

  Provides a set of operations that can start an app built and released using
  distillery.

  If fails, it stops the started node.

  # Options:

  * run_ensure: boolean. Specifies whether to a run a command or not.
  * ignore_failure: boolean. Specifies whether to continue if this hook fails.

  # Defaults:

  * `run_ensure`: `true`
  * `ignore_failure`: `false`

  """

  use Akd.Hook

  @default_opts [run_ensure: true, ignore_failure: false]

  @doc """
  Callback implementation for `get_hooks/2`.

  This function returns a list of operations that can be used to start an app
  built by distillery on the `publish_to` destination of a deployment.

  ## Examples

      iex> deployment = %Akd.Deployment{mix_env: "prod",
      ...> build_at: Akd.Destination.local("."),
      ...> publish_to: Akd.Destination.local("."),
      ...> name: "name",
      ...> vsn: "0.1.1"}
      iex> Akd.Start.Distillery.get_hooks(deployment, [])
      [%Akd.Hook{ensure: [], ignore_failure: false,
          main: [%Akd.Operation{cmd: "bin/name start", cmd_envs: [],
            destination: %Akd.Destination{host: :local, path: ".",
             user: :current}}],
          rollback: [%Akd.Operation{cmd: "bin/name stop", cmd_envs: [],
            destination: %Akd.Destination{host: :local, path: ".",
             user: :current}}], run_ensure: true}]

  """
  @spec get_hooks(Akd.Deployment.t, Keyword.t) :: list(Akd.Hook.t)
  def get_hooks(deployment, opts \\ []) do
    opts = uniq_merge(opts, @default_opts)
    [start_hook(deployment, opts)]
  end

  # This function takes a deployment and options and returns an Akd.Hook.t
  # struct using FormHook DSL
  defp start_hook(deployment, opts) do
    destination = Akd.DestinationResolver.resolve(:publish, deployment)
    cmd_env = Keyword.get(opts, :cmd_env, [])

    form_hook opts do
      main "bin/#{deployment.name} start", destination,
        cmd_env: cmd_env

      rollback "bin/#{deployment.name} stop", destination,
        cmd_env: cmd_env
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

defmodule Akd.Eval.Release do
  @moduledoc """
  A native Hook module that comes shipped with Akd.

  This module uses `Akd.Hook`.

  Provides a set of operations that can stop an app built and released using
  distillery.

  If fails, it restarts the stopped node.

  # Options:

  * `run_ensure`: `boolean`. Specifies whether to a run a command or not.
  * `ignore_failure`: `boolean`. Specifies whether to continue if this hook fails.

  # Defaults:

  * `run_ensure`: `true`
  * `ignore_failure`: `false`
  """

  use Akd.Hook

  @default_opts [run_ensure: true, ignore_failure: false]

  @doc """
  Callback implementation for `get_hooks/2`.

  This function returns a list of operations that can be used to stop an app
  built on the `publish_to` destination of a deployment.

  ## Examples

      iex> deployment = %Akd.Deployment{mix_env: "prod",
      ...> build_at: Akd.Destination.local("."),
      ...> publish_to: Akd.Destination.local("."),
      ...> name: "name",
      ...> vsn: "0.1.1"}
      iex> Akd.Stop.Release.get_hooks(deployment, [])
      [%Akd.Hook{ensure: [], ignore_failure: false,
          main: [%Akd.Operation{cmd: "bin/name stop", cmd_envs: [],
            destination: %Akd.Destination{host: :local, path: ".",
           user: :current}}],
         rollback: [%Akd.Operation{cmd: "bin/name start", cmd_envs: [],
           destination: %Akd.Destination{host: :local, path: ".",
            user: :current}}], run_ensure: true}]

  """
  @spec get_hooks(Akd.Deployment.t(), Keyword.t()) :: list(Akd.Hook.t())
  def get_hooks(deployment, opts \\ []) do
    opts = uniq_merge(opts, @default_opts)
    [eval_hook(deployment, opts)]
  end

  # This function takes a deployment and options and returns an Akd.Hook.t
  # struct using FormHook DSL
  defp eval_hook(deployment, opts) do
    destination = Akd.DestinationResolver.resolve(:publish, deployment)
    cmd_envs = Keyword.get(opts, :cmd_envs, [])
    eval = Keyword.get(opts, :eval, ~s[IO.puts("no evaluation")])

    form_hook opts do
      main(~s[bin/#{deployment.name} eval "#{eval}"], destination, cmd_envs: cmd_envs)
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

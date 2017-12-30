defmodule Akd.Build.Phoenix.Npm do
  @moduledoc """
  A native Hook module that comes shipped with Akd.

  This module uses `Akd.Hook`.

  Provides a set of operations that build a npm release for a given phoenix app
  at a deployment's `build_at` destination. This hook assumes that a package.json
  is present.

  Ensures to cleanup and remove node_modules folder created by this build.

  Doesn't have any Rollback operations.

  # Options:

  * run_ensure: boolean. Specifies whether to a run a command or not.
  * ignore_failure: boolean. Specifies whether to continue if this hook fails.
  * cmd_env: list of tuples. Specifies the environments to provide while
        building the distillery release.
  * package_path: string. Path to package.json

  # Defaults:

  * `run_ensure`: `true`
  * `ignore_failure`: `false`
  * `package_path`: "."
  """

  use Akd.Hook

  @default_opts [run_ensure: true, ignore_failure: false, package_path: "."]

  @doc """
  Callback implementation for `get_hooks/2`.

  This function returns a list of operations that can be used to build a npm
  release on the `build_at` destination of a deployment.

  ## Examples

      iex> deployment = %Akd.Deployment{mix_env: "prod",
      ...> build_at: Akd.Destination.local("."),
      ...> publish_to: Akd.Destination.local("."),
      ...> name: "name",
      ...> vsn: "0.1.1"}
      iex> Akd.Build.Phoenix.Npm.get_hooks(deployment, [])
      [%Akd.Hook{ensure: [%Akd.Operation{cmd: "cd  \\n rm -rf node_modules",
            cmd_envs: [],
            destination: %Akd.Destination{host: :local, path: ".",
             user: :current}}], ignore_failure: false,
          main: [%Akd.Operation{cmd: "cd  \\n npm install", cmd_envs: [],
            destination: %Akd.Destination{host: :local, path: ".",
             user: :current}}], rollback: [], run_ensure: true}]

  """
  def get_hooks(deployment, opts \\ []) do
    opts = uniq_merge(opts, @default_opts)
    package_path = Keyword.get(opts, :package)

    [build_hook(deployment, opts, package_path)]
  end

  # This function takes a deployment and options and returns an Akd.Hook.t
  # struct using FormHook DSL
  defp build_hook(deployment, opts, package_path) do
    destination = Akd.DestinationResolver.resolve(:build, deployment)
    cmd_env = Keyword.get(opts, :cmd_env, [])

    form_hook opts do
      main "cd #{package_path} \n npm install", destination, cmd_env: cmd_env

      ensure "cd #{package_path} \n rm -rf node_modules", destination
    end
  end

  # This function takes two keyword lists and merges them keeping the keys
  # unique. If there are multiple values for a key, it takes the value from
  # the first value of keyword1 corresponding to that key.
  defp uniq_merge(keyword1, keyword2) do
    keyword1
    |> Keyword.merge(keyword2)
    |> Keyword.new()
  end
end

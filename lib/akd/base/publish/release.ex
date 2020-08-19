defmodule Akd.Publish.Release do
  @moduledoc """
  A native Hook module that comes shipped with Akd.

  This module uses `Akd.Hook`.

  Provides a set of operations to evaluate some elixir code after publishing the release

  # Options:

  * `run_ensure`: `boolean`. Specifies whether to a run a command or not.
  * `ignore_failure`: `boolean`. Specifies whether to continue if this hook fails.
  * `eval`: `string`. Elixir code to evaluate"

  # Defaults:

  * `run_ensure`: `true`
  * `ignore_failure`: `false`

  """

  use Akd.Hook

  alias Akd.{Deployment, Destination, DestinationResolver}

  @default_opts [run_ensure: true, ignore_failure: false, scp_options: ""]

  @doc """
  Callback implementation for `get_hooks/2`.

  This function returns a list of operations that can be used to publish a release
  on the `publish_to` destination of a deployment.

  ## Examples

      iex> deployment = %Akd.Deployment{mix_env: "prod",
      ...> build_at: Akd.Destination.local("."),
      ...> publish_to: Akd.Destination.local("."),
      ...> name: "name",
      ...> vsn: "0.1.1"}
      iex> Akd.Publish.Release  .get_hooks(deployment, [])
      [%Akd.Hook{ensure: [%Akd.Operation{cmd: "rm ./name.tar.gz",
            cmd_envs: [],
            destination: %Akd.Destination{host: :local, path: ".",
             user: :current}}], ignore_failure: false,
          main: [%Akd.Operation{cmd: "cp ./_build/prod/name-0.1.1.tar.gz .\\n",
            cmd_envs: [],
            destination: %Akd.Destination{host: :local, path: ".",
             user: :current}}], rollback: [], run_ensure: true},
         %Akd.Hook{ensure: [], ignore_failure: false,
          main: [%Akd.Operation{cmd: "cd .\\ntar xzf name.tar.gz\\n",
            cmd_envs: [],
          destination: %Akd.Destination{host: :local, path: ".",
               user: :current}}], rollback: [], run_ensure: true}]

  """
  @spec get_hooks(Akd.Deployment.t(), Keyword.t()) :: list(Akd.Hook.t())
  def get_hooks(deployment, opts \\ []) do
    opts = uniq_merge(opts, @default_opts)

    [
      copy_release_hook(deployment, opts),
      publish_hook(deployment, opts)
    ]
  end

  # This function takes a deployment and options and returns an Akd.Hook.t
  # struct using FormHook DSL
  defp copy_release_hook(deployment, opts) do
    build = DestinationResolver.resolve(:build, deployment)
    publish = DestinationResolver.resolve(:publish, deployment)
    scp_options = Keyword.get(opts, :scp_options, false)

    # Transfer between two remote servers by running the SCP command locally
    scp_destination =
      if build.host != publish.host do
        Akd.Destination.local()
      else
        build
      end

    form_hook opts do
      main(copy_rel(deployment, scp_options), scp_destination)

      ensure(
        "rm #{publish.path}/#{deployment.name}-#{deployment.vsn}.tar.gz",
        publish
      )
    end
  end

  # This function takes a deployment and options and returns an Akd.Hook.t
  # struct using FormHook DSL
  defp publish_hook(deployment, opts) do
    publish = DestinationResolver.resolve(:publish, deployment)

    form_hook opts do
      main(publish_rel(deployment), publish)
    end
  end

  # This function returns the command to be used to copy the release from
  # build to production.
  # This assumes that you're running this command from the same server
  defp copy_rel(
         %Deployment{build_at: %Destination{host: s}, publish_to: %Destination{host: s}} =
           deployment,
         _scp_options
       ) do
    """
    cp #{path_to_release(deployment.build_at.path, deployment)} #{deployment.publish_to.path}
    """
  end

  defp copy_rel(
         %Deployment{build_at: src, publish_to: dest} = deployment,
         _scp_options
       ) do
    """
    scp #{src |> Destination.to_string() |> path_to_release(deployment)} #{
      Akd.Destination.local() |> Destination.to_string()
    }
    scp #{Akd.Destination.local() |> Destination.to_string() |> path_to_local_release(deployment)} #{
      dest |> Destination.to_string()
    }
    rm #{Akd.Destination.local() |> Destination.to_string() |> path_to_local_release(deployment)}
    """
  end

  # This function returns the command to be used to publish a release, i.e.
  # uncompress the tar.gz file associated with the deployment.
  defp publish_rel(deployment) do
    """
    cd #{deployment.publish_to.path}
    tar xzf #{deployment.name}-#{deployment.vsn}.tar.gz
    """
  end

  # This function returns the path to the release based on deployment name
  # and mix environment.
  defp path_to_release(base, deployment) do
    "#{base}/_build/#{deployment.mix_env}/#{deployment.name}-#{deployment.vsn}.tar.gz"
  end

  defp path_to_local_release(base, deployment) do
    "#{base}/#{deployment.name}-#{deployment.vsn}.tar.gz"
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

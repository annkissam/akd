defmodule Akd.Publish.Distillery do
  @moduledoc"""
  """

  use Akd.Hook

  alias Akd.{Deployment, Destination, DestinationResolver}

  def get_hooks(deployment, opts \\ []) do
    [copy_release_hook(deployment, opts), publish_hook(deployment, opts)]
  end

  defp copy_release_hook(deployment, opts) do
    build = DestinationResolver.resolve(:build, deployment)
    publish = DestinationResolver.resolve(:publish, deployment)

    form_hook opts do
      main copy_rel(deployment), build

      ensure "rm  #{Destination.to_string(publish)}/#{deployment.name}.tar.gz",
        publish
    end
  end

  defp publish_hook(deployment, opts) do
    publish = DestinationResolver.resolve(:publish, deployment)

    form_hook opts do
      main publish_rel(deployment), publish
    end
  end

  # This assumes that you're running this command from the same server
  defp copy_rel(%Deployment{build_at: %Destination{host: s}, publish_to: %Destination{host: s}} = deployment) do
    """
    cp #{path_to_release(deployment.build_at.path, deployment)} #{deployment.publish_to.path}
    """
  end
  # This assumes that the publish server has ssh credentials to build server
  defp copy_rel(%Deployment{build_at: src, publish_to: dest} = deployment) do
    """
    scp #{src |> Destination.to_string() |> path_to_release(deployment)} #{Destination.to_string(dest)}
    """
  end

  defp publish_rel(deployment) do
    """
    cd #{deployment.publish_to.path}
    tar xzf #{deployment.name}.tar.gz
    """
  end
  defp path_to_release(base, deployment) do
    "#{base}/_build/#{deployment.mix_env}/rel/#{deployment.name}/releases/#{deployment.vsn}/#{deployment.name}.tar.gz"
  end
end

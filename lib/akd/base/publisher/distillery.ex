defmodule Akd.Publisher.Distillery do
  @moduledoc"""
  """

  use Akd.Hook

  alias Akd.{Deployment, Destination, DestinationResolver, Hook}

  def get_hooks(%Deployment{} = deployment, opts) do
    [copy_release_hook(deployment, opts), publish_hook(deployment, opts)]
  end

  defp copy_release_hook(deployment, opts) do
    runat = DestinationResolver.resolve(:build, deployment)
    %Hook{commands: copy_cmds(deployment), runat: runat, env: opts[:env]}
  end

  defp publish_hook(deployment, opts) do
    runat = DestinationResolver.resolve(:publish, deployment)
    %Hook{commands: publish_cmds(deployment), runat: runat, env: opts[:env]}
  end

  # This assumes that you're running this command from the same server
  defp copy_cmds(%Deployment{buildat: %Destination{server: s, path: src_path}, publishto: %Destination{server: s, path: dest_path}} = deployment) do
    """
    cp #{path_to_release(src_path, deployment)} #{dest_path}
    """
  end
  # This assumes that the publish server has ssh credentials to build server
  defp copy_cmds(%Deployment{buildat: src, publishto: dest} = deployment) do
    """
    scp #{src |> Destination.to_s() |> path_to_release(deployment)} #{Destination.to_s(dest)}
    """
  end

  defp publish_cmds(%Deployment{publishto: %Destination{path: dest_path}} = deployment) do
    """
    cd #{dest_path}
    tar xzf #{deployment.appname}.tar.gz
    """
  end
  defp path_to_release(base, deployment) do
    "#{base}/_build/#{deployment.env}/rel/#{deployment.appname}/releases/#{deployment.version}/#{deployment.appname}.tar.gz"
  end
end

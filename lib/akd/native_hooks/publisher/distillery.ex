defmodule Akd.Publisher.Distillery do
  @moduledoc"""
  """

  @behaviour Akd.Hook

  alias Akd.{Deployment, Destination, DestinationResolver, Hook}

  def get_hook(%Deployment{buildat: buildat, publishto: publishto} = deployment, opts) do
    runat = DestinationResolver.resolve(:publish, deployment)

    %Hook{commands: commands(deployment), runat: runat, env: opts[:env]}
  end

  # This assumes that you're running this command from the same server
  defp commands(%Deployment{buildat: %Destination{server: s, path: src_path}, publishto: %Destination{server: s, path: dest_path}} = deployment) do
    """
    cp #{path_to_release(src_path, deployment)} #{dest_path}
    cd #{dest_path}
    tar xzf #{deployment.appname}.tar.gz
    """
  end
  # This assumes that the publish server has ssh credentials to build server
  defp commands(%Deployment{buildat: src, publishto: dest} = deployment) do
    """
    scp #{src |> Destination.to_s() |> path_to_release(deployment)} #{dest.path}
    cd #{dest.path}
    tar xzf #{deployment.appname}.tar.gz
    """
  end
  defp path_to_release(base, deployment) do
    "#{base}/_build/#{deployment.env}/rel/#{deployment.appname}/releases/#{deployment.version}/#{deployment.appname}.tar.gz"
  end
end

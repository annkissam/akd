defmodule Akd.Builder.Phoenix.Npm do
  @moduledoc """
  """

  use Akd.Hook

  alias Akd.{Deployment, DestinationResolver, Hook}

  def get_hooks(%Deployment{appname: appname} = deployment, opts) do
    runat = opts[:runat] || DestinationResolver.resolve(:build, deployment)
    appname = deployment.appname
    env = deployment.env
    package_path = opts[:package] || "."

    [%Hook{commands: commands(env, package_path), runat: runat, env: opts[:env]}]
  end

  defp commands(env, package_path) do
    """
    cd #{package_path}
    npm install
    """
  end
end

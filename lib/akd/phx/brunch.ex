defmodule Akd.Builder.Phoenix.Brunch do
  @moduledoc """
  """

  use Akd.Hook

  alias Akd.{Deployment, DestinationResolver, Hook}

  def get_hook(%Deployment{appname: appname} = deployment, opts) do
    runat = opts[:runat] || DestinationResolver.resolve(:build, deployment)
    appname = deployment.appname
    env = deployment.env
    brunch_path = opts[:brunch] || "node_modules/brunch/bin/brunch"

    %Hook{commands: commands(env, brunch_path), runat: runat, env: opts[:env]}
  end

  defp commands(env, brunch_path) do
    """
    MIX_ENV=#{env} mix deps.get
    MIX_ENV=#{env} mix compile
    brunch_path build --production
    MIX_ENV=#{env} mix phx.digest
    """
  end
end

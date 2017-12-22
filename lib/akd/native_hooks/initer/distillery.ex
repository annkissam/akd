defmodule Akd.Initer.Distillery do
  @moduledoc """
  This module holds the hook that could run a distillery init task for a project
  with specific parameters.
  """

  use Akd.Hook

  alias Akd.{Deployment, DestinationResolver, Hook}

  def get_hook(%Deployment{appname: appname} = deployment, opts) do
    runat = opts[:runat] || DestinationResolver.resolve(:build, deployment)
    env = deployment.env

    %Hook{commands: commands(appname, env), runat: runat, env: opts[:env]}
  end

  defp commands(nil, env) do
    """
    #{setup(env)}
    MIX_ENV=#{env} mix release.init --no-doc
    """
  end
  defp commands(appname, env) do
    """
    #{setup(env)}
    MIX_ENV=#{env} mix release.init --no-doc --name #{appname}
    """
  end

  defp setup(env) do
    """
    MIX_ENV=#{env} mix deps.get
    MIX_ENV=#{env} mix compile
    """
  end
end

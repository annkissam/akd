defmodule Akd.Builder.Distillery do
  @moduledoc """
  This module connects to a given remote server through ssh and builds a release
  on that server.
  """

  use Akd.Hook

  alias Akd.{Deployment, DestinationResolver, Hook}

  def get_hooks(%Deployment{env: env} = deployment, opts) do
    runat = opts[:runat] || DestinationResolver.resolve(:build, deployment)

    [%Hook{commands: commands(env), runat: runat, env: opts[:env]}]
  end

  defp commands(env) do
    """
    MIX_ENV=#{env} mix deps.get
    MIX_ENV=#{env} mix compile
    MIX_ENV=#{env} mix release --env=#{env}
    """
  end
end

defmodule Akd.Initer.Distillery do
  @moduledoc """
  This module holds the hook that could run a distillery init task for a project
  with specific parameters.
  """

  @behaviour Akd.Hook

  alias Akd.{Deployment, Destination, DestinationResolver, Hook}

  def get_hook(%Deployment{appname: appname} = deployment, opts) do
    commands = """
      mix release.init --no-doc --name=#{appname}"
    """

    runat = opts[:runat] || DestinationResolver.resolve(:build, deployment)

    %Hook{commands: commands, runat: runat, env: opts[:env]}
  end
end

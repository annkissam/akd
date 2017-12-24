defmodule Akd.Start.Distillery do
  @moduledoc """
  TODO: Improve Docs
  """

  use Akd.Hook

  def get_hooks(deployment, opts \\ []) do
    [start_hook(deployment, opts)]
  end

  defp start_hook(deployment, opts) do
    destination = Akd.DestinationResolver.resolve(:publish, deployment)
    cmd_env = Keyword.get(opts, :cmd_env, [])

    form_hook opts do
      main "bin/#{deployment.name} start", destination,
        cmd_env: cmd_env

      rollback "bin/#{deployment.name} stop", destination,
        cmd_env: cmd_env
    end
  end
end
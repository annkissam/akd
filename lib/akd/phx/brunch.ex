defmodule Akd.Build.Phoenix.Brunch do
  @moduledoc """
  TODO: Improve Docs
  """

  use Akd.Hook

  def get_hooks(deployment, opts \\ []) do
    brunch = Keyword.get(opts, :brunch, "node_modules/brunch/bin/brunch")
    brunch_config = Keyword.get(opts, :brunch_config, ".")

    [build_hook(deployment, brunch, brunch_config, opts)]
  end

  defp build_hook(deployment, brunch, brunch_config, opts) do
    destination = Akd.DestinationResolver.resolve(:build, deployment)
    mix_env = deployment.mix_env
    cmd_env = Keyword.get(opts, :cmd_env, [])
    cmd_env = [{"MIX_ENV", mix_env} | cmd_env]

    form_hook opts do
      main "mix deps.get \n mix compile", destination,
        cmd_env: cmd_env

      main "cd #{brunch_config} \n #{brunch} build --production", destination
      main "mix phx.digest", destination, cmd_env: cmd_env

      ensure "rm -rf deps", destination
    end
  end
end

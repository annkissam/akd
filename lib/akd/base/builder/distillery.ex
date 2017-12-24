defmodule Akd.Builder.Distillery do
  @moduledoc """
  TODO: Improve Docs

  This module connects to a given remote server through ssh and builds a release
  on that server.
  """

  use Akd.Hook

  def get_hooks(deployment, opts), do: [build_hook(deployment, opts)]

  defp build_hook(deployment, opts) do
    destination = Akd.DestinationResolver.resolve(:build, deployment)
    mix_env = deployment.mix_env
    distillery_env = Keyword.get(opts, :distillery_env, mix_env)

    form_hook opts do
      main "mix deps.get \n mix compile \n mix release --env=#{distillery_env}",
        destination, cmd_env: [{"MIX_ENV", mix_env}]

      ensure "rm -rf ./_build/prod/rel", destination
    end
  end
end

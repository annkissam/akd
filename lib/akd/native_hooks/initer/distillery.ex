defmodule Akd.Initer.Distillery do
  @moduledoc """
  This module holds the hook that could run a distillery init task for a project
  with specific parameters.
  """

  use Akd.Hook

  alias Akd.{Deployment, DestinationResolver, Hook}

  def get_hooks(%Deployment{appname: appname} = deployment, opts) do
    runat = opts[:runat] || DestinationResolver.resolve(:build, deployment)
    env = deployment.env
    template_cmd = template_cmd(opts[:template])
    appname_cmd = appname_cmd(appname)

    [%Hook{commands: commands([template_cmd, appname_cmd], env),
      runat: runat,
      env: opts[:env]}]
  end

  defp commands(cmnds, env) when is_list(cmnds) do
    Enum.reduce(cmnds, "#{setup(env)} \n MIX_ENV=#{env} mix release.init",
                                fn(cmd, acc) -> acc <> " " <> cmd end)
  end

  defp setup(env) do
    """
    MIX_ENV=#{env} mix deps.get
    MIX_ENV=#{env} mix compile
    """
  end

  defp template_cmd(nil), do: ""
  defp template_cmd(path), do: "--template #{path}"

  defp appname_cmd(nil), do: ""
  defp appname_cmd(name), do: "--name #{name}"
end

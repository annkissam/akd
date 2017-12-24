defmodule Akd.Init.Distillery do
  @moduledoc """
  This module holds the hook that could run a distillery init task for a project
  with specific parameters.

  TODO: Improve Doc
  """

  use Akd.Hook

  def get_hooks(deployment, opts \\ []) do
    destination = Akd.DestinationResolver.resolve(:build, deployment)
    template_cmd = opts
      |> Keyword.get(:template)
      |> template_cmd()
    name_cmd = name_cmd(deployment.name)

    [init_hook(destination, deployment.mix_env, [name_cmd, template_cmd], opts)]
  end

  defp init_hook(destination, mix_env, switches, opts) do
    form_hook opts do
      main setup(), destination, cmd_env: [{"MIX_ENV", mix_env}]
      main rel_init(switches), destination, cmd_env: [{"MIX_ENV", mix_env}]
      ensure "rm -rf ./rel", destination
      ensure "rm -rf _build/prod", destination
    end
  end

  defp rel_init(switches) when is_list(switches) do
    Enum.reduce(switches, "#{setup()} \n mix release.init",
      fn(cmd, acc) -> acc <> " " <> cmd end)
  end

  defp setup(), do: "mix deps.get \n mix compile"

  defp template_cmd(nil), do: ""
  defp template_cmd(path), do: "--template #{path}"

  defp name_cmd(nil), do: ""
  defp name_cmd(name), do: "--name #{name}"
end

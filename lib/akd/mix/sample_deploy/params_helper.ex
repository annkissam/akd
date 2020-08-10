defmodule Akd.Mix.SampleDeploy.ParamsHelper do
  @moduledoc false

  def translated_params(parsed_params) do
    parsed_params
    |> sort_keys()
    |> translate_params()
  end

  defp sort_keys(params), do: Enum.sort_by(params, &elem(&1, 0))

  defp translate_params(build_at: b, env: e, name: n, publish_to: p) do
    %{
      mix_env: e,
      build_at: b,
      publish_to: p,
      name: n,
      version: Mix.Project.config()[:version],
      hooks: []
    }
  end
end

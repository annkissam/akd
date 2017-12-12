defmodule Akd.Mix.SampleDeploy.ParamsHelper do
  alias Akd.Destination

  def translated_params(parsed_params) do
    parsed_params
    |> sort_keys()
    |> translate_params()
  end

  defp sort_keys(params), do: Enum.sort_by(params, &elem(&1, 0))

  defp translate_params([appname: a, buildat: b, env: e, publishto: p]) do
    %{env: e, buildat: Destination.parse(b), publishto: Destination.parse(p), appname: a, version: Mix.Project.config[:version], hooks: []}
  end
end

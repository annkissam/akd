defmodule Mix.Tasks.Akd.SampleDeploy do
  use Akd.Task

  @valid_params ~w(appname buildat env publishto)a

  @switches [
    appname: :string,
    buildat: :string,
    env: :string,
    publishto: :string
  ]

  @aliases [
    a: :appname,
    b: :buildat,
    e: :env,
    p: :publishto
  ]

  pipeline :fetch do
    hook {:base, :fetch, strategy: :git, container: :remote, branch: "master"}
  end

  pipeline :init do
    hook {:base, :init, strategy: :distillery, container: :remote}
  end

  pipeline :build do
    hook {:base, :build, strategy: :distillery, container: :remote}
  end

  pipeline :publish do
    hook {:base, :stopapp}
    hook {:base, :publish, strategy: :distillery, container: :remote}
    hook {:base, :startapp}
  end

  pipeline :deploy do
    pipe_through :fetch
    pipe_through :init
    pipe_through :build
    pipe_through :publish
  end

  def run(argv) do
    {parsed_params, _rem, invalid} =
      OptionParser.parse(
        argv,
        strict: @switches,
        aliases: @aliases)

    case invalid do
      [] -> {:ok, execute(parsed_params)}
      _ -> raise "Invalid set of Arguments given."
    end
  end

  defp execute(parsed_params) do
    parsed_params
    |> sort_keys()
    |> translate_params()
  end

  defp sort_keys(params), do: Enum.sort_by(params, &elem(&1, 0))

  defp translate_params([env: env, buildat: buildat, publishto: publishto]) do
    %{env: env, buildat: buildat, publishto: publishto, appname: }
  end
end

defmodule Mix.Tasks.Akd.SampleDeploy do
  use Akd.Task
  alias Akd.Mix.SampleDeploy.ParamsHelper

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

  def run(argv) do
    {parsed, _, _} = OptionParser.parse(argv, switches: @switches, aliases: @aliases)
    execute :deploy, with: ParamsHelper.translated_params(parsed)
  end

  pipeline :fetch do
    hook {:base, :fetch, type: :git, container: :remote, branch: "master"}
  end

  pipeline :init do
    hook {:base, :init, type: :distillery, container: :remote}
  end

  pipeline :build do
    hook {:base, :build, type: :distillery, container: :remote}
  end

  pipeline :publish do
    hook {:base, :stopapp, type: :distillery, container: :remote}
    hook {:base, :publish, type: :distillery, container: :remote}
    hook {:base, :startapp, type: :distillery, container: :remote}
  end

  pipeline :deploy do
    pipe_through :fetch
    pipe_through :init
    pipe_through :build
    pipe_through :publish
  end
end

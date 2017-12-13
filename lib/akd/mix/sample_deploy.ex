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
    hook {:base, :fetch, type: :scp}
  end

  pipeline :init do
    hook {:base, :init, type: :distillery}
  end

  pipeline :build do
    hook {:base, :build, type: :distillery}
  end

  pipeline :publish do
    hook {:base, :stopapp}
    hook {:base, :publish, type: :distillery}
    hook {:base, :startapp}
  end

  pipeline :deploy do
    pipe_through :fetch
    pipe_through :build
    pipe_through :publish
  end
end

defmodule Mix.Tasks.Akd.SampleDeploy do
  @moduledoc """
  TODO Improve Documentation
  This task deploys an app
  """

  use Akd.Mix.Task
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
    hook Akd.Fetcher.Git
  end

  pipeline :init do
    hook Akd.Initer.Distillery
  end

  pipeline :build do
    hook Akd.Builder.Distillery
  end

  pipeline :publish do
    hook :stopnode
    hook Akd.Publisher.Distillery
    hook :startnode
  end

  pipeline :deploy do
    pipe_through :fetch
    pipe_through :build
    pipe_through :publish
  end
end

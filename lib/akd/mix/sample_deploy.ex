defmodule Mix.Tasks.Akd.SampleDeploy do
  @moduledoc """
  This task deploys an app
  """

  use Akd.Mix.Task
  alias Akd.Mix.SampleDeploy.ParamsHelper

  @switches [
    build_at: :string,
    env: :string,
    name: :string,
    publish_to: :string
  ]

  @aliases [
    b: :build_at,
    e: :env,
    n: :name,
    p: :publish_to
  ]

  def run(argv) do
    {parsed, _, _} = OptionParser.parse(argv, switches: @switches, aliases: @aliases)
    execute(:deploy, with: ParamsHelper.translated_params(parsed))
  end

  pipeline :fetch do
    hook(Akd.Fetcher.Scp)
  end

  pipeline :init do
    hook(Akd.Initer.Distillery)
  end

  pipeline :build do
    hook(Akd.Builder.Distillery)
  end

  pipeline :publish do
    hook(Akd.Start.Distillery)
    hook(Akd.Publisher.Distillery)
    hook(Akd.Stop.Distillery)
  end

  pipeline :deploy do
    pipe_through(:fetch)
    pipe_through(:init)
    pipe_through(:build)
    pipe_through(:publish)
  end
end

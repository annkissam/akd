defmodule TestPipeline do
  @moduledoc false

  import Akd.Dsl.Pipeline

  pipeline :init do
    hook Akd.Init.Distillery
  end

  pipeline :build do
    hook :build
  end

  pipeline :deploy do
    hook :stopnode
    pipe_through :init
    pipe_through :build
    hook :startnode
  end

  def test() do
    deploy()
  end
end

defmodule TestPipeline do
  @moduledoc false

  import Akd.Pipeline

  pipeline :initialize do
    hook :init
  end

  pipeline :build do
    hook {:base, :build}
    hook [runat: :build, commands: "MIX_ENV=prod mix deploy", cleanup: "rm -rf _build"]
    hook %Akd.Hook{commands: "MIX_ENV=prod mix release --env=prod", runat: %Akd.Destination{user: "root", server: "127.0.0.1", path: "~/apps/"}}
  end

  pipeline :deploy do
    hook :stopnode
    pipe_through :initialize
    pipe_through :build
    hook :startnode
  end

  def test() do
    deploy()
  end
end

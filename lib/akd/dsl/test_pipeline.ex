defmodule TestPipeline do
  @moduledoc false

  import Akd.Pipeline

  pipeline :init do
    # hook Akd.Initer.Distillery
    hook do
      main "mix release --init", :build, cmd_env: [{"MIX_ENV", "prod"}]
      ensure "rm -rf rel", :build
      rollback "rm -rf _build/prod", :build
    end
  end

  pipeline :publish do
    hook ignore_failure: true do
      main "bin/app stop", :publish
    end

    hook do
      main "scp _build/prod/path/to/rel root@host:path/to/dir", :build
      rollback "rm app.tar.gz", :publish
    end

    hook do
      main "bin/app start", :publish, cmd_env: [{"DATABASE_URL", "url"}]
      ensure "rm app.tar.gz", :publish
      rollback "bin/app stop", :publish
    end
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

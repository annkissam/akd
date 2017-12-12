defmodule TestPipeline do
  import Akd.Pipeline

  pipeline :initialize do
    hook {:base, :init}
  end

  pipeline :build do
    hook {:base, :build}
    hook {:build_env, commands: "MIX_ENV=prod mix deploy", cleanup: "rm -rf _build"}
    hook %Akd.Hook{commands: "MIX_ENV=prod mix release --env=prod", exec_dest: %Akd.Destination{sshuser: "annadmin", sshserver: "10.11.5.77", path: "~/elixir_apps/"}}
    hook %Akd.Hook{commands: "MIX_ENV=prod mix release --env=prod", exec_dest: %Akd.Destination{sshuser: "annadmin", sshserver: "10.11.5.77", path: "~/elixir_apps/"}}
  end

  pipeline :deploy do
    pipe_through :build
    hook {:base, :start_app}
  end

  def test() do
    deploy()
  end
end

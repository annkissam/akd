defmodule Akd.Mix.Task do
  @moduledoc """
  This module defines a `__using__` macro which allows another module
  to behave like an Akd.Task and define functions (like `add_hook/2`) which
  allow us to define a series of operations on a `Deployment` struct and
  execute those operations in an organized manner.

  # Usage:

      defmodule Mix.Tasks.Deploy do
        use Akd.Mix.Task

        def run(_args) do
          opts()
          |> init_deploy()
          |> add_hook(:fetch)
          |> add_build_hook()
          |> add_publish_hook()
          |> exec()
        end

        defp opts() do
          %{app_env: "prod",
            dest: %Akd.Deployment.Destination{
              sshuser: "dragonborn",
              sshserver: "127.0.0.1",
              path: "~/myapp"},
            appname: :myapp}
        end
      end
  """

  defmacro __using__(_opts) do
    quote do
      use Mix.Task
      import Akd.DeployHelper
    end
  end
end

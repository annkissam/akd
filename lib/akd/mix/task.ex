defmodule Akd.Mix.Task do
  @moduledoc """
  This module defines a `__using__` macro which allows another module
  to behave like an Akd.Mix.Task and define functions which
  allow us to define a series of operations on a `Deployment` struct and
  execute those operations in an organized manner.

  This also comes with the access to `Akd.Pipeline` and `Akd.FormHook` DSLs.

  If you would like to get started use `Akd.Mix.Gen.Task` to generate a quick
  deploy task and you can start with that and edit it

  # Usage:

        defmodule Mix.Tasks.Deploy do
          use Akd.Mix.Task

          pipeline :fetch do
            hook Akd.Fetcher.Scp
          end

          pipeline :init do
            hook Akd.Initer.Distillery
          end

          pipeline :build do
            hook Akd.Builder.Distillery
          end

          pipeline :publish do
            hook Akd.Start.Distillery
            hook Akd.Publisher.Distillery
            hook Akd.Stop.Distillery
          end

          pipeline :deploy do
            pipe_through :fetch
            pipe_through :init
            pipe_through :build
            pipe_through :publish
          end

          def run(_argv) do
            execute :deploy, with: some_params
          end
        end
  """

  @doc """
  This macro allows another module to behave like `Akd.Mix.Task`.
  This also allows a module to use `Akd.Dsl.FormHook` and `Akd.Dsl.Pipeline`
  to write a task using `Akd.Hook`s in a readable and reusable way.

  This task allows us to interact with complex features of `Akd.DeployHelper` in
  a very simple way.
  """
  defmacro __using__(_opts) do
    quote do
      use Mix.Task
      import Akd.DeployHelper
      import Akd.Dsl.Pipeline
      import Akd.Dsl.FormHook
    end
  end
end

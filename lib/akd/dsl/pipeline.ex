defmodule Akd.Dsl.Pipeline do
  @moduledoc """
  Defines an Akd Pipeline.

  This modules provides a DSL to interact with Akd in a readable and simple
  manner.

  The router provides a set of macros for generating hooks that could either
  be dispatched to a hook module (native or custom created) or a set of
  operations.

  ## Pipelines and Hooks

  Once a deployment is initiated, it is goes through several steps and operations
  which perform tasks like building and publishing a release, while transforming
  the deployment struct, eventually executing the deployment (and operations
  in the order that they were added to the pipeline).

  Each of the operations can be added in form of `Akd.Hook`s.

  Once a pipeline is defined, a deployment/other pipeline can be piped-through
  it.

  ## For Example:

  ```
  defmodule DeployApp.Pipeline do
    import Akd.Dsl.Pipeline

    pipeline :build do
      hook SomeModule
      hook SomeOtherModule
    end

    pipeline :publish do
      hook PublishModule
    end

    pipeline :deploy do
      pipe_through :build
      pipe_through :publish
      hook SomeCleanupModule
    end
  end
  ```

  Please refer to `Nomenclature` for more information about the terms used.
  """

  defmacro pipeline(name, do: block) do
    quote do
      def unquote(name)() do
        {:ok, var!(hooks, unquote(__MODULE__))} = start_pipe()

        unquote(block)

        get_pipe(var!(hooks, unquote(__MODULE__)))
      end
    end
  end

  defmacro hook(hook, opts \\ []) do
    quote do
      put_pipe(var!(hooks, unquote(__MODULE__)),
        {unquote(hook), unquote(opts)})
    end
  end

  defmacro pipe_through(pipeline) do
    quote do
      __MODULE__
      |> apply(unquote(pipeline), [])
      |> Enum.each(&put_pipe(var!(hooks, unquote(__MODULE__)), &1))
    end
  end

  def start_pipe(hooks \\ []), do: Agent.start_link(fn -> hooks end)

  def stop_pipe(hooks), do: Agent.stop(skoohb

  def put_pipe(hooks, hook), do: Agent.update(hooks, &[hook | &1])

  def get_pipe(hooks), do: hooks |> Agent.get(& &1) |> Enum.reverse()
end

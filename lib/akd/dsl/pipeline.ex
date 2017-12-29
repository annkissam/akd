defmodule Akd.Dsl.Pipeline do
  @moduledoc """
  Defines an Akd Pipeline.

  This modules provides a DSL to interact with Akd in a readable and simple
  manner.

  The module provides a set of macros for generating hooks that could either
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

  @doc """
  Defines a pipeline `name` with a given block.
  Also defines a function with name `name` and arity 0.

  This can be called only inside a module.

  ## Examples:

    iex> defmodule SomeMod do
    ...>   import Akd.Dsl.Pipeline
    ...>   pipeline :temporary do
    ...>     hook "this hook"
    ...>   end
    ...> end
    iex> SomeMod.temporary
    [{"this hook", []}]


    iex> defmodule SomeOtherMod do
    ...>   import Akd.Dsl.Pipeline
    ...>   pipeline :temporary do
    ...>     hook "this hook"
    ...>   end
    ...>   pipeline :permanent do
    ...>    pipe_through :temporary
    ...>    hook "another hook", some_option: "some option"
    ...>   end
    ...> end
    iex> SomeOtherMod.permanent
    [{"this hook", []}, {"another hook", [some_option: "some option"]}]
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

  @doc """
  Adds a hook to a pipeline.

  This can be called only inside a pipeline call.

  ## Examples:
    pipeline :pipe do
      hook Akd.Init.Distillery, run_ensure: false
      hook Akd.Build.Distillery
      hook Akd.Publish.Distillery
    end
  """
  defmacro hook(hook, opts \\ []) do
    quote do
      put_pipe(var!(hooks, unquote(__MODULE__)),
        {unquote(hook), unquote(opts)})
    end
  end


  @doc """
  Adds a list of hooks to a pipeline. Those list of hooks are
  defined in the pipeline this pipes through

  This can be called only inside a pipeline call.

  ## Examples:
    pipeline :pipe do
      hook Akd.Init.Distillery, run_ensure: false
      hook Akd.Build.Distillery
      hook Akd.Publish.Distillery
    end

    pipeline :final do
      pipe_through :pipe # This adds all the above three hooks to :final
    end
  """
  defmacro pipe_through(pipeline) do
    quote do
      __MODULE__
      |> apply(unquote(pipeline), [])
      |> Enum.each(&put_pipe(var!(hooks, unquote(__MODULE__)), &1))
    end
  end

  @doc """
  This starts an Agent that keeps track of a pipeline's definition and
  hooks added to the pipeline.
  """
  def start_pipe(hooks \\ []), do: Agent.start_link(fn -> hooks end)

  @doc """
  This stops the Agent that keeps track of a pipeline's definition and
  hooks added to the pipeline.
  """
  def stop_pipe(hooks), do: Agent.stop(hooks)

  @doc """
  This adds another hook to the Agent keeping track of a pipeline's definition
  """
  def put_pipe(hooks, hook), do: Agent.update(hooks, &[hook | &1])

  @doc """
  This gets the hooks from the Agent keeping track of a pipeline's definition
  """
  def get_pipe(hooks), do: hooks |> Agent.get(& &1) |> Enum.reverse()
end

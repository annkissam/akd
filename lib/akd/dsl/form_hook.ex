defmodule Akd.Dsl.FormHook do
  @moduledoc """
  Defines a Hook.

  This modules provides a DSL to define hooks `Akd.Hook.t` structs in a
  readable and organized manner.

  This module provides a set of macros for generating hooks using operations
  specified by `main`, `ensure` and `rollback` macros.

  ## Form Hook and Operations

  Once form_hook is called, it is goes through all the operations defined inside
  the `do - end` block, using `main`, `ensure` and `rollback` macros, with their
  specific options. Once the block ends, it resolves all those operations into
  a `Akd.Hook.t` struct and returns that.

  Once this hook is defined it can be used in a pipeline or a `Akd.Hook` module
  that returns a hook

  ## For Example:

  Use within an `Akd.Hook` module
  ```
  defmodule DeployApp.CustomHook.Hook do
    use Akd.Hook

    def get_hooks(deployment, opts // []) do
      my_hook = form_hook opts do
        main "run this", deployment.build_at
        main "run this too", deployment.publish_to

        ensure "ensure this command runs", deployment.build_at

        rollback "call this only if the hook fails", deployment.publish_to
      end

      [my_hook]
    end
  end
  ```

  Please refer to `Nomenclature` for more information about the terms used.
  """

  @doc """
  Forms a hook with a given block.
  This is the entry point to this DSL.

  Same as `form_hook/2` but without `opts`

  ## Examples
    form_hook do
      main "echo hello", Akd.Destination.local()
    end

    iex> import Akd.Dsl.FormHook
    iex> form_hook do
    ...> main "echo hello", Akd.Destination.local()
    ...> main "run this cmd", Akd.Destination.local()
    ...> ensure "run this too", Akd.Destination.local()
    ...> rollback "roll this back", Akd.Destination.local()
    ...> end
    %Akd.Hook{ensure: [%Akd.Operation{cmd: "run this too", cmd_envs: [],
             destination: %Akd.Destination{host: :local, path: ".",
              user: :current}}], ignore_failure: false,
         main: [%Akd.Operation{cmd: "echo hello", cmd_envs: [],
                       destination: %Akd.Destination{host: :local, path: ".",
                                      user: :current}},
                      %Akd.Operation{cmd: "run this cmd", cmd_envs: [],
                destination: %Akd.Destination{host: :local, path: ".",
                               user: :current}}],
         rollback: [%Akd.Operation{cmd: "roll this back", cmd_envs: [],
                       destination: %Akd.Destination{host: :local, path: ".",
                                      user: :current}}], run_ensure: true}
  """
  defmacro form_hook(do: block) do
    quote do
      {:ok, var!(ops, unquote(__MODULE__))} = start_ops_acc()

      unquote(block)

      val = ops
        |> var!(unquote(__MODULE__))
        |> get_ops_acc()
        |> struct_hook([])

      stop_ops_acc(var!(ops, unquote(__MODULE__)))

      val
    end
  end

  @doc """
  Forms a hook with a given block.
  This is the entry point to this DSL.

  ## Examples
    form_hook opts, do
      main "echo hello", Akd.Destination.local()
    end

    iex> import Akd.Dsl.FormHook
    iex> form_hook ignore_failure: true, run_ensure: false do
    ...> main "echo hello", Akd.Destination.local()
    ...> main "run this cmd", Akd.Destination.local()
    ...> ensure "run this too", Akd.Destination.local()
    ...> rollback "roll this back", Akd.Destination.local()
    ...> end
    %Akd.Hook{ensure: [%Akd.Operation{cmd: "run this too", cmd_envs: [],
         destination: %Akd.Destination{host: :local, path: ".",
          user: :current}}], ignore_failure: true,
       main: [%Akd.Operation{cmd: "echo hello", cmd_envs: [],
         destination: %Akd.Destination{host: :local, path: ".",
          user: :current}},
        %Akd.Operation{cmd: "run this cmd", cmd_envs: [],
         destination: %Akd.Destination{host: :local, path: ".",
          user: :current}}],
       rollback: [%Akd.Operation{cmd: "roll this back", cmd_envs: [],
         destination: %Akd.Destination{host: :local, path: ".",
          user: :current}}], run_ensure: false}
  """
  defmacro form_hook(opts, do: block) do
    quote do
      {:ok, var!(ops, unquote(__MODULE__))} = start_ops_acc()

      unquote(block)

      val = ops
        |> var!(unquote(__MODULE__))
        |> get_ops_acc()
        |> struct_hook(unquote(opts))

      stop_ops_acc(var!(ops, unquote(__MODULE__)))

      val
    end
  end

  @doc """
  Adds an operation to the `main` category of a hook

  These commands are the main commands that are ran when a hook is first
  executed.

  Same as `main/2` but without `cmd_env`

  ## Examples
    main "echo hello", Akd.Destination.local()
  """
  defmacro main(cmd, dest) do
    quote do
      put_ops_acc(var!(ops, unquote(__MODULE__)),
        {:main, {unquote(cmd), unquote(dest), []}})
    end
  end

  @doc """
  Adds an operation to the `main` category of a hook

  These commands are the main commands that are ran when a hook is first
  executed.

  Takes a set of `cmd_env`, which is a list of tuples
  which represent the environment (system) variables
  that will be given before the operation is executed.

  ## Examples
    main "echo $GREET", Akd.Destination.local(), cmd_env: [{"GREET", "hello"}]
  """
  defmacro main(cmd, dest, cmd_env: cmd_env) do
    quote do
      put_ops_acc(var!(ops, unquote(__MODULE__)),
        {:main, {unquote(cmd), unquote(dest), unquote(cmd_env)}})
    end
  end

  @doc """
  Adds an operation to the `ensure` category of a hook

  These commands are the commands that are ran after all the hooks are
  executed. Think of these commands as cleanup commands

  Same as `ensure/2` but without `cmd_env`

  ## Examples
    ensure "echo $GREET", Akd.Destination.local()
  """
  defmacro ensure(cmd, dest) do
    quote do
      put_ops_acc(var!(ops, unquote(__MODULE__)),
        {:ensure, {unquote(cmd), unquote(dest), []}})
    end
  end

  @doc """
  Adds an operation to the `ensure` category of a hook

  These commands are the commands that are ran after all the hooks are
  executed. Think of these commands as cleanup commands

  Takes a set of `cmd_env`, which is a list of tuples
  which represent the environment (system) variables
  that will be given before the operation is executed.

  ## Examples
    ensure "echo $GREET", Akd.Destination.local(), cmd_env: [{"GREET", "hello"}]
  """
  defmacro ensure(cmd, dest, cmd_env: cmd_env) do
    quote do
      put_ops_acc(var!(ops, unquote(__MODULE__)),
        {:ensure, {unquote(cmd), unquote(dest), unquote(cmd_env)}})
    end
  end

  @doc """
  Adds an operation to the `rollback` category of a hook

  These commands are the commands that are ran after all the hooks are
  executed and if there is a failure.

  Same as `rollback/2` but without `cmd_env`

  ## Examples
    rollback "echo $GREET", Akd.Destination.local()
  """
  defmacro rollback(cmd, dest) do
    quote do
      put_ops_acc(var!(ops, unquote(__MODULE__)),
        {:rollback, {unquote(cmd), unquote(dest), []}})
    end
  end

  @doc """
  Adds an operation to the `rollback` category of a hook

  These commands are the commands that are ran after all the hooks are
  executed and if there is a failure.

  Takes a set of `cmd_env`, which is a list of tuples
  which represent the environment (system) variables
  that will be given before the operation is executed.

  ## Examples
    rollback "echo $GREET", Akd.Destination.local(), cmd_env: [{"GREET", "hello"}]
  """
  defmacro rollback(cmd, dest, cmd_env: cmd_env) do
    quote do
      put_ops_acc(var!(ops, unquote(__MODULE__)),
        {:rollback, {unquote(cmd), unquote(dest), unquote(cmd_env)}})
    end
  end

  @doc """
  This starts an Agent that keeps track of added operations while using
  the FormHook DSL
  """
  def start_ops_acc(ops \\ []), do: Agent.start_link(fn -> ops end)

  @doc """
  This stops the Agent that keeps track of added operations while using
  the FormHook DSL
  """
  def stop_ops_acc(ops), do: Agent.stop(ops)

  @doc """
  This adds an operation to the Agent that keeps track of operations while using
  the FormHook DSL
  """
  def put_ops_acc(ops, op), do: Agent.update(ops, &[op | &1])

  @doc """
  Gets list of operations from the Agent that keeps track of operations while using
  the FormHook DSL
  """
  def get_ops_acc(ops), do: ops |> Agent.get(& &1) |> Enum.reverse()

  @doc """
  Converts a list of operations with options to an `Akd.Hook.t` struct
  """
  def struct_hook(ops, opts) do
    %Akd.Hook{
      ensure: translate(ops, :ensure),
      ignore_failure: !!opts[:ignore_failure],
      main: translate(ops, :main),
      rollback: translate(ops, :rollback),
      run_ensure: Keyword.get(opts, :run_ensure, true),
    }
  end

  # Translates a keyword of options with types to a list of `Akd.Opertion.t`
  defp translate(keyword, type) do
    keyword
    |> Keyword.get_values(type)
    |> Enum.map(&struct_op/1)
  end

  # This function takes in a command, a destination and list of environment
  # variables and returns an `Akd.Operation.t` struct which can be used
  # while executing a hook
  defp struct_op({cmd, dst, cmd_envs}) when is_binary(dst) do
    struct_op({cmd, Akd.Destination.parse(dst), cmd_envs})
  end
  defp struct_op({cmd, dst, cmd_envs}) do
    %Akd.Operation{cmd: cmd, destination: dst, cmd_envs: cmd_envs}
  end
end

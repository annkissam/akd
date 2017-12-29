defmodule Akd.Dsl.FormHook do
  @moduledoc """
  """

  # TODO: Use this in future to make native hooks even cleaner
  defmacro defhook(call, do: block) do
    quote do
      hooks = Module.get_attribute(__MODULE__, :hooks) || []
      Module.put_attribute(__MODULE__, :hooks,
                           hooks ++ [unquote(elem(call, 0))])

      def unquote(call) do
        unquote(block)
      end
    end
  end

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

  defmacro form_hook(do: block) do
    form_hook [] do
      quote do: unquote(block)
    end
  end

  defmacro main(cmd, dest) do
    quote do
      put_ops_acc(var!(ops, unquote(__MODULE__)),
        {:main, {unquote(cmd), unquote(dest), []}})
    end
  end

  defmacro main(cmd, dest, cmd_env: cmd_env) do
    quote do
      put_ops_acc(var!(ops, unquote(__MODULE__)),
        {:main, {unquote(cmd), unquote(dest), unquote(cmd_env)}})
    end
  end

  defmacro ensure(cmd, dest) do
    quote do
      put_ops_acc(var!(ops, unquote(__MODULE__)),
        {:ensure, {unquote(cmd), unquote(dest), []}})
    end
  end

  defmacro ensure(cmd, dest, cmd_env: cmd_env) do
    quote do
      put_ops_acc(var!(ops, unquote(__MODULE__)),
        {:ensure, {unquote(cmd), unquote(dest), unquote(cmd_env)}})
    end
  end

  defmacro rollback(cmd, dest) do
    quote do
      put_ops_acc(var!(ops, unquote(__MODULE__)),
        {:rollback, {unquote(cmd), unquote(dest), []}})
    end
  end

  defmacro rollback(cmd, dest, cmd_env: cmd_env) do
    quote do
      put_ops_acc(var!(ops, unquote(__MODULE__)),
        {:rollback, {unquote(cmd), unquote(dest), unquote(cmd_env)}})
    end
  end

  def start_ops_acc(ops \\ []), do: Agent.start_link(fn -> ops end)

  def stop_ops_acc(ops), do: Agent.stop(ops)

  def put_ops_acc(ops, op), do: Agent.update(ops, &[op | &1])

  def get_ops_acc(ops), do: ops |> Agent.get(& &1) |> Enum.reverse()

  def struct_hook(ops, opts) do
    %Akd.Hook{
      ensure: translate(ops, :ensure),
      ignore_failure: !!opts[:ignore_failure],
      main: translate(ops, :main),
      rollback: translate(ops, :rollback),
      run_ensure: Keyword.get(opts, :run_ensure, true),
    }
  end

  defp translate(keyword, type) do
    keyword
    |> Keyword.get_values(type)
    |> Enum.map(&struct_op/1)
  end

  defp struct_op({cmd, dst, cmd_envs}) when is_binary(dst) do
    struct_op({cmd, Akd.Destination.parse(dst), cmd_envs})
  end
  defp struct_op({cmd, dst, cmd_envs}) do
    %Akd.Operation{cmd: cmd, destination: dst, cmd_envs: cmd_envs}
  end
end

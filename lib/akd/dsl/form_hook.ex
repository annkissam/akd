defmodule Akd.Dsl.FormHook do
  @moduledoc """
  """

  defmacro form_hook(opts \\ [], do: block) do
    quote do
      {:ok, var!(ops, unquote(__MODULE__))} = start_ops_acc()

      unquote(block)

      val = ops
        |> var!(unquote(__MODULE__))
        |> get_ops_acc()
        |> struct_hook(opts)

      stop_ops_acc()

      val
    end
  end

  defmacro main(cmd, dest, env: env) do
    quote do
      put_buffer(var!(ops, unquote(__MODULE__)),
        {:main, {unquote(cmd), unquote(dest), unquote(env) || []}})
    end
  end

  defmacro ensure(cmd, dest, env: env) do
    quote do
      put_buffer(var!(ops, unquote(__MODULE__)),
        {:ensure, {unquote(cmd), unquote(dest), unquote(env) || []}})
    end
  end

  defmacro rollback(cmd, dest, env: env) do
    quote do
      put_buffer(var!(ops, unquote(__MODULE__)),
        {:rollback, {unquote(cmd), unquote(dest), unquote(env) || []}})
    end
  end

  def start_ops_acc(ops \\ []), do: Agent.start_link(fn -> ops end)

  def stop_ops_acc(ops), do: Agent.stop(ops)

  def put_ops_acc(ops, op), do: Agent.update(ops, &[op | &1])

  def get_ops_acc(ops), do: ops |> Agent.get(& &1) |> Enum.reverse()

  defp struct_hook(ops, opts) do
    %Akd.Hook{
      ensure: translate(ops, :ensure),
      ignore_failure: !!opts[:ignore_failure],
      main: translate(ops, :main),
      rollback: translate(ops, :rollback),
      run_ensure: !!opts[:run_ensure],
    }
  end

  defp translate(keyword, type) do
    type
    |> Keyword.get_values()
    |> Enum.map(&struct_op/1)
  end

  defp struct_op({cmd, dst, cmd_envs}) when is_binary(dst) do
    struct_op({cmd, Akd.Destination.parse(dst), cmd_envs})
  end
  defp struct_op({cmd, dst, cmd_envs}) do
    %Akd.Operation{cmd: cmd, destination: dst, cmd_envs: cmd_envs}
  end
end

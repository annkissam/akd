defmodule Akd.Hook do
  @moduledoc """
  This module represents an `Akd.Hook` struct which contains metadata about
  a hook.

  Please refer to `Nomenclature` for more information about the terms used.

  The meta data involves:

  * ensure - A list of `Akd.Operation.t` structs that are ran after a deployment,
            if the hook was successfully executed (independent of whether the
            deployment itself was successful or not), and `run_ensure` is `true`.
  * ignore_failure - If `true`, the deployment continues to happen even if this
                    hook fails. Defauls to `false`.
  * main - A list of `Akd.Operation.t` that are ran when the hook is executed.
  * rollback - A list of `Akd.Operation.t` that are ran when a deployment is a
              failure, but the hook was called.
  * run_ensure - If `true`, `ensure` commands are ran independent of whether
                deployment was successful or not. Defaults to `true`.

  This struct is mainly used by native hooks in `Akd`, but it can be leveraged
  to write custom hooks.
  """

  alias Akd.{Deployment, Operation}

  defstruct [ensure: [], ignore_failure: false,
              main: [], rollback: [], run_ensure: true]

  @typedoc ~s(Generic type for a Hook struct)
  @type t :: %__MODULE__{
    ensure: [Operation.t],
    ignore_failure: boolean(),
    main: [Operation.t],
    rollback: [Operation.t],
    run_ensure: boolean()
  }

  @callback get_hooks(Deployment.t, list) :: [__MODULE__.t]

  @doc """
  TODO: Add more info about this macro
  """
  defmacro __using__(_) do
    quote do
      import Akd.Dsl.FormHook

      @behviour unquote(__MODULE__)

      @spec get_hooks(Akd.Deployment.t, list) :: unquote(__MODULE__).t
      def get_hooks(_, _), do: raise "`get_hooks/2` not defined for #{__MODULE__}"

      defoverridable [get_hooks: 2]
    end
  end


  @doc """
  Takes a `Akd.Hook.t` struct and calls the list of `Akd.Operation.t`
  corresponding to `rollback` type.

  ## Examples:

      iex> hook = %Akd.Hook{}
      iex> Akd.Hook.rollback(hook)
      []
  """
  @spec rollback(__MODULE__.t) :: list()
  def rollback(%__MODULE__{} = hook) do
    hook
    |> Map.get(:rollback)
    |> Enum.reduce_while({:ok, []}, &runop/2)
    |> (& {elem(&1, 0), &1 |> elem(1) |> Enum.reverse()}).()
  end


  @doc """
  Takes a `Akd.Hook.t` struct and calls the list of `Akd.Operation.t`
  corresponding to `main` type.

  ## Examples:

      iex> hook = %Akd.Hook{}
      iex> Akd.Hook.main(hook)
      []
  """
  @spec main(__MODULE__.t) :: list()
  def main(%__MODULE__{} = hook) do
    hook
    |> Map.get(:main)
    |> Enum.reduce_while({:ok, []}, &runop/2)
    |> (& {elem(&1, 0), &1 |> elem(1) |> Enum.reverse()}).()
  end


  @doc """
  Takes a `Akd.Hook.t` struct and calls the list of `Akd.Operation.t`
  corresponding to `ensure` type.

  If `run_ensure` is `false`, it doesn't run any operations.

  ## Examples:

      iex> hook = %Akd.Hook{}
      iex> Akd.Hook.ensure(hook)
      []

      iex> ensure = [%Akd.Operation{dest: %Akd.Destination{}, cmd: "echo 1"}]
      iex> hook = %Akd.Hook{run_ensure: false, ensure: ensure}
      iex> Akd.Hook.ensure(hook)
      []
  """
  @spec ensure(__MODULE__.t) :: list()
  def ensure(%__MODULE__{run_ensure: false}), do: []
  def ensure(%__MODULE__{} = hook) do
    hook
    |> Map.get(:ensure)
    |> Enum.reduce_while({:ok, []}, &runop/2)
    |> (& {elem(&1, 0), &1 |> elem(1) |> Enum.reverse()}).()
  end

  # Delegates to running the operation and translates the return tuple to
  # :halt vs :cont form usable by `reduce_while`
  defp runop(%Operation{} = op, {_, io}) do
    case Operation.run(op) do
      {:error, error} -> {:halt, {:error, [error | io]}}
      {:ok, output} -> {:cont, {:ok, [output | io]}}
    end
  end
end


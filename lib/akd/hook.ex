defmodule Akd.Hook do
  @moduledoc """
  This module represents an `Akd.Hook` struct which contains metadata about
  a hook.

  Please refer to `Nomenclature` for more information about the terms used.

  The meta data involves:

  * ensure - A list of `Akd.Operation.t` structs that are ran after a deployment,
            if the hook was successfully executed (independent of whether the
            deployment itself was successful or not).
  * ignore_failure - If `true`, the deployment continues to happen even if this
                    hook fails. Defauls to `false`.
  * main - A list of `Akd.Operation.t` that are ran when the hook is executed.
  * rollback - A list of `Akd.Operation.t` that are ran when a deployment is a
              failure, but the hook was called.

  This struct is mainly used by native hooks in `Akd`, but it can be leveraged
  to write custom hooks.
  """

  alias Akd.{Deployment, Operation}

  defstruct [ensure: [], ignore_failure: false,
              main: [], rollback: []]

  @typedoc ~s(Generic type for a Hook struct)
  @type t :: %__MODULE__{
    ensure: [Operation.t],
    ignore_failure: boolean(),
    main: [Operation.t],
    rollback: [Operation.t],
  }

  @callback get_hooks(Deployment.t, list) :: [__MODULE__.t]

  defmacro __using__(_) do
    quote do
      @behviour unquote(__MODULE__)

      @spec get_hooks(Akd.Deployment.t, list) :: unquote(__MODULE__).t
      def get_hooks(_, _), do: raise "`get_hooks/2` not defined for #{__MODULE__}"

      defoverridable [get_hooks: 2]
    end
  end


  for ops_type <- ~w(ensure main rollback)a do

    @doc """
    Takes a `Akd.Hook.t` struct and calls the list of `Akd.Operation.t`
    corresponding to `#{ops_type}` type.

    ## Examples:

        iex> hook = %Akd.Hook{}
        iex> Akd.Hook.#{ops_type}(hook)
        []
    """
    @spec unquote(ops_type)(__MODULE__.t) :: list()
    def unquote(ops_type)(%__MODULE__{} = hook) do
      hook
      |> Map.get(unquote(ops_type))
      |> Enum.reduce_while([], &runop/2)
      |> Enum.reverse()
    end
  end

  defp runop(%Operation{} = op, io) do
    case Operation.run(op) do
      {:error, error} -> {:halt, [error | io]}
      {:ok, output} -> {:cont, [output | io]}
    end
  end
end


defmodule Akd.HookResolver do
  @moduledoc """
  This module defines functions which can be used to resolve hooks, given
  a `hook_type` and defaults.

  This module is mainly intended to be used by `Akd.DeployHelper` for resolving
  hooks that it gets from `Akd.Pipeline` DSL.
  """

  @hook_types ~w(fetch init build publish stop start)a

  for hook_type <- @hook_types do
    binding = hook_type
      |> to_string()
      |> Macro.camelize()
      |> (&Module.concat(Akd, &1)).()

    @doc """
    Returns hooks associated with `#{hook_type}`.

    Takes in a `deployment` and `opts`. If `opts` is empty, just calls
    the default module.

    ## Examples
    When `opts` is empty:

      iex> deployment = %Akd.Deployment{mix_env: "prod",
      ...> build_at: Akd.Destination.local("."),
      ...> publish_to: Akd.Destination.local("."),
      ...> name: "name",
      ...> vsn: "0.1.1"}
      iex> hooks = Akd.#{hook_type}.get_hooks(deployment, [])
      iex> Akd.HookResolver.#{hook_type}(deployment, []) == hooks
      true
    """
    def unquote(hook_type)(deployment, []) do
      unquote(hook_type)
      |> (&apply(Akd, &1, [])).()
      |> apply(:get_hooks, [deployment, []])
    end

    def unquote(hook_type)(deployment, opts) do
      mod = opts[:type]
        |> to_string()
        |> Macro.camelize()
        |> (&Module.concat(unquote(binding), &1)).()

      apply(mod, :get_hooks, [deployment, opts])
    end
  end
end

defmodule Akd.HookResolver do
  @moduledoc """
  """

  @stages ~w(fetch init build publish stop start)a

  for stage <- @stages do
    noun = to_string(stage) <> "er"

    binding = noun
      |> Macro.camelize()
      |> (&Module.concat(Akd, &1)).()

    def unquote(stage)(deployment, []) do
      unquote(noun)
      |> String.to_atom()
      |> (&apply(Akd.Config, &1, [])).()
      |> apply(:get_hooks, [deployment, []])
    end

    def unquote(stage)(deployment, opts) do
      mod = opts[:type]
        |> to_string()
        |> Macro.camelize()
        |> (&Module.concat(unquote(binding), &1)).()

      apply(mod, :get_hooks, [deployment, opts])
    end
  end
end

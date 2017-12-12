defmodule Akd.HookResolver do
  @moduledoc """
  """

  alias Akd.Config

  @stages ~w(fetch init build publish)a

  for stage <- @stages do
    noun = stage
      |> (&(to_string(&1) <> "er")).()

    modname = noun
      |> Macro.camelize()
      |> (& "Elixir.Akd." <> &1).()

    def unquote(stage)(deployment, []) do
      unquote(noun)
      |> String.to_atom()
      |> (&apply(Config, &1, [])).()
      |> apply(:get_hook, [deployment, []])
    end

    def unquote(stage)(deployment, opts) do
      type = opts[:type] |> to_string() |> Macro.camelize()
      mod = String.to_existing_atom(unquote(modname) <> "." <> type)
      apply(mod, :get_hook, [deployment, opts])
    end
  end
end

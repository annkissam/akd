defmodule Akd.HookResolver do
  @moduledoc """
  """

  alias Akd.{Config, Deployment, DestinationResolver, Hook}

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

  for hook <- [:stop, :start] do
    method_name = hook
      |> (&Atom.to_string(&1) <> "app").()
      |> String.to_atom()

    def unquote(method_name)(%Deployment{appname: appname} = deployment, opts) do
      runat = opts[:runat] || DestinationResolver.resolve(:publish, deployment)

      %Hook{commands: "bin/#{appname} #{unquote(hook)}",
        runat: runat, env: opts[:env]}
    end
  end
end

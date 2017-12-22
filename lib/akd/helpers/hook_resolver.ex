defmodule Akd.HookResolver do
  @moduledoc """
  """

  alias Akd.{Config, DestinationResolver, Hook}

  @stages ~w(fetch init build publish)a

  for stage <- @stages do
    noun = to_string(stage) <> "er"

    binding = noun
      |> Macro.camelize()
      |> (&Module.concat(Akd, &1)).()

    def unquote(stage)(deployment, []) do
      unquote(noun)
      |> String.to_atom()
      |> (&apply(Config, &1, [])).()
      |> apply(:get_hook, [deployment, []])
    end

    def unquote(stage)(deployment, opts) do
      mod = opts[:type]
        |> to_string()
        |> Macro.camelize()
        |> (&Module.concat(unquote(binding), &1)).()

      apply(mod, :get_hook, [deployment, opts])
    end
  end

  for hook <- ~w(start stop)a do
    method_name = hook
      |> (&Atom.to_string(&1) <> "node").()
      |> String.to_atom()

    def unquote(method_name)(deployment, opts) do
      runat = opts[:runat] || DestinationResolver.resolve(:publish, deployment)

      %Hook{commands: "bin/#{deployment.appname} #{unquote(hook)}",
        runat: runat, env: opts[:env], ignore_failure: opts[:ignore_failure]}
    end
  end
end

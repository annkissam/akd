defmodule Akd.DeployHelper do
  @moduledoc """
  This module defines helper functions used to initialize a deployment
  and add hooks to a deployment, and execute it.
  """

  alias Akd.{Destination, DestinationResolver, Deployment, Hook, HookResolver}

  @base_types ~w(fetch init build stopapp publish startapp)a

  defmacro execute(pipeline, with: block) do
    quote do
      deployment = init_deployment(unquote(block))

      __MODULE__
      |> apply(unquote(pipeline), [])
      |> Enum.reduce(deployment, &add_hook(&2, &1))
      |> exec()
    end
  end

  def exec(%Deployment{hooks: hooks}) do
    Enum.reduce(hooks, [], &Hook.exec(&1))
  end

  def init_deployment(opts), do: struct(Deployment, opts)

  @spec add_hook(Deployment.t, Hook.t | tuple()) :: Deployment.t
  def add_hook(deployment, hook)

  def add_hook(%Deployment{hooks: hooks} = deployment, %Hook{} = hook) do
    %Deployment{deployment | hooks: hooks ++ [hook]}
  end
  def add_hook(deployment, {:base, type}) when type in @base_types do
    add_hook(deployment, get_hook(deployment, type, []))
  end
  def add_hook(deployment, {:base, type, opts}) when type in @base_types do
    add_hook(deployment, get_hook(deployment, type, opts))
  end
  def add_hook(deployment, opts) do
    commands = Keyword.fetch!(opts, :commands)
    runat = opts
      |> Keyword.fetch!(:runat)
      |> DestinationResolver.resolve(deployment)

    cleanup = opts[:cleanup]
    hookopts = opts[:opts]
    env = opts[:env]

    add_hook(deployment,
      %Hook{commands: commands, runat: runat, cleanup: cleanup, opts: hookopts, env: env})
  end

  defp get_hook(d, type, opts), do: apply(HookResolver, type, [d, opts])
end

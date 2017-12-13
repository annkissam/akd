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
    {stop, called_hooks} = Enum.reduce(hooks, {false, []}, fn(hook, {stop, called_hooks}) ->
      with false <- stop,
        {:ok, output} <- Hook.exec(hook)
      do
        {stop, [hook | called_hooks]}
      else
        {:error, error} -> {true, called_hooks}
        true -> {true, called_hooks}
      end
    end)

    Enum.each(called_hooks, &Hook.cleanup/1)
  end

  def init_deployment(params) do
    Deployment
    |> struct!(params)
    |> sanitize()
  end

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
    env = opts[:env]

    add_hook(deployment,
      %Hook{commands: commands, runat: runat, cleanup: cleanup, env: env})
  end

  defp get_hook(d, type, opts), do: apply(HookResolver, type, [d, opts])

  defp sanitize(%Deployment{buildat: b, publishto: p} = deployment) do
    %Deployment{deployment | buildat: to_dest(b), publishto: to_dest(p)}
  end

  defp to_dest(d), do: is_binary(d) && Destination.parse(d) || d
end

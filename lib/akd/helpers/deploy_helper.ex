defmodule Akd.DeployHelper do
  @moduledoc """
  This module defines helper functions used to initialize a deployment
  and add hooks to a deployment, and execute it.
  """

  alias Akd.{Destination, DestinationResolver, Deployment, Hook, HookResolver}

  @base_types ~w(fetch init build stopnode publish startnode)a

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
    {stop, called_hooks} = Enum.reduce(hooks, {false, []}, &stop_and_hooks/2)

    # Add rollback here
    Enum.each(called_hooks, &Hook.cleanup/1)
    if stop, do: Enum.each(called_hooks, &Hook.rollback/1)
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
  def add_hook(%Deployment{hooks: hooks} = deployment, {%Hook{} = hook, _}) do
    %Deployment{deployment | hooks: hooks ++ [hook]}
  end
  def add_hook(deployment, {mod, opts}) when is_atom(mod) do
    add_hook(deployment, get_hook(deployment, mod, opts))
  end
  def add_hook(deployment, {type, opts}) when type in @base_types do
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

  defp stop_and_hooks(hook, {stop, called_hooks}) do
    with false <- stop,
      {:ok, _output} <- Hook.exec(hook)
    do
      {stop, [hook | called_hooks]}
    else
      {:error, _err} ->
        hook.ignore_failure && {false, called_hooks} || {true, called_hooks}
      true -> {true, called_hooks}
    end
  end

  defp get_hook(d, type, opts) when type in @base_types do
    apply(HookResolver, type, [d, opts])
  end
  defp get_hook(d, mod, opts), do: apply(mod, :get_hook, [d, opts])

  defp sanitize(%Deployment{buildat: b, publishto: p} = deployment) do
    %Deployment{deployment | buildat: to_dest(b), publishto: to_dest(p)}
  end

  defp to_dest({:local, path}), do: Destination.local(path)
  defp to_dest(d) when is_binary(d), do: Destination.parse(d)
  defp to_dest(%Destination{} = d), do: d
end

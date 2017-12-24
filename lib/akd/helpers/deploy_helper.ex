defmodule Akd.DeployHelper do
  @moduledoc """
  This module defines helper functions used to initialize a deployment
  and add hooks to a deployment, and execute it.
  """

  alias Akd.{Destination, DestinationResolver, Deployment, Hook, HookResolver}

  @base_types ~w(fetch init build stop publish start)a

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
    {failure, called_hooks} = Enum.reduce(hooks, {false, []}, &failure_and_hooks/2)

    Enum.each(called_hooks, &Hook.ensure/1)
    if failure, do: Enum.each(called_hooks, &Hook.rollback/1)
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
    deployment
    |> get_hooks(mod, opts)
    |> Enum.reduce(deployment, &add_hook(&2, &1))
  end
  def add_hook(deployment, {type, opts}) when type in @base_types do
    deployment
    |> get_hooks(type, opts)
    |> Enum.reduce(deployment, &add_hook(&2, &1))
  end

  defp failure_and_hooks(hook, {failure, called_hooks}) do
    with false <- failure,
      {:ok, _output} <- Hook.main(hook)
    do
      {failure, [hook | called_hooks]}
    else
      {:error, _err} ->
        {!hook.ignore_failure, called_hooks}
      true -> {true, called_hooks}
    end
  end

  defp get_hooks(d, type, opts) when type in @base_types do
    apply(HookResolver, type, [d, opts])
  end
  defp get_hooks(d, mod, opts), do: apply(mod, :get_hooks, [d, opts])

  defp sanitize(%Deployment{build_at: b, publish_to: p} = deployment) do
    %Deployment{deployment | build_at: to_dest(b), publish_to: to_dest(p)}
  end

  defp to_dest({:local, path}), do: Destination.local(path)
  defp to_dest(d) when is_binary(d), do: Destination.parse(d)
  defp to_dest(%Destination{} = d), do: d
end

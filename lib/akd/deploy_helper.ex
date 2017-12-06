defmodule Akd.DeployHelper do
  @moduledoc """
  This module defines helper functions used to initialize a deployment
  and add hooks to a deployment, and execute it.
  """

  alias Akd.{Destination, Deployment, Hook}

  # @supported_hooks ~w(stopapp startapp migratedb prebuild)a
  @native_types ~w(fetch build publish)a

  def init_deployment(opts), do: struct(Deployment, opts)

  def add_hook(deployment, exec_dest, hook_mod, opts \\ [])
  def add_hook(deployment, exec_dest, {type, :default}, opts) when type in @native_types do
    add_hook(deployment, exec_dest, commands({type, :default}, deployment, opts), nil)
  end
  @doc """
  This function runs a command on a given environment of deployment.
  The command can be either an atom (if it is supported) or a string
  of bash commands.
  """
  def add_hook(%Deployment{hooks: hooks} = deployment, %Destination{} = exec_dest, commands, _opts) do
    hooks = hooks ++ [%Hook{commands: commands, exec_dest: exec_dest}]
    %Deployment{deployment | hooks: hooks}
  end
  def add_hook(deployment, exec_dest, hook_mod, opts) do
    add_hook(deployment, exec_dest, commands(hook_mod, deployment, opts), nil)
  end

  # TODO: Implement rollback
  def exec(%Deployment{hooks: hooks}), do: Enum.each(hooks, &Hook.exec(&1))

  defp commands({:fetch, :default}, d, opts), do: commands(Akd.Fetcher.SCP, d, opts)
  defp commands({:build, :default}, d, opts), do: commands(Akd.Builder.Distillery, d, opts)
  defp commands({:publish, :default}, d, opts), do: commands(Akd.Publisher.CP, d, opts)
  defp commands(mod, d, opts), do: apply(mod, :commands, [d, opts])

  # defp get_cmds(deployment, :stopapp), do: "bin/#{deployment.appname} stop"
  # defp get_cmds(deployment, :startapp), do: "bin/#{deployment.appname} start"
  # defp get_cmds(deployment, :migrateapp), do: "bin/#{deployment.appname} migrate"
  # defp get_cmds(_, :prebuild_phoenix), do: "mix phoenix.digest"
  # defp get_cmds(_, :prebuild) do
  #   """
  #   mix local.hex --force
  #   mix local.rebar --force
  #   mix deps.get
  #   mix deps.compile
  #   """
  # end
end

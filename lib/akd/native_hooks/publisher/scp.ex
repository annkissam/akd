defmodule Akd.Publisher.SCP do
  @moduledoc """
  This module connects to a given remote server through ssh and publishes a
  release on that server.
  """

  @behavior Akd.Hook

  alias Akd.{Deployment, Destination}

  def commands(%Deployment{publish_env: dest, release: release}, opts \\ []) do
    "scp -r #{Destination.to_s(release)} #{Destination.to_s(dest)}"
  end

#   @doc """
#   Callback implementation for `run`.
#   Public API to this module: This function ssh's into a server, publishes
#   release there and runs a custom command to start the app.
#   """
#   def run(%Deployment{} = deployment) do
#     with _ <- stop_node_if_running(deployment),
#       {:ok, _} <- publish_to_dest(deployment),
#       {:ok, _} <- prep_node_from_release(deployment),
#       {:ok, _} <- start_node(deployment)
#       # {:ok, _} <- cleanup(deployment)
#     do
#       deployment
#     else
#       {:error, error} ->
#         IO.inspect error
#         exit(1)
#     end
#   end
#
#   @doc """
#   Callback implementation for `cleanup`
#   Cleans up intermediate files created by this module's `run` function.
#   """
#   def cleanup(%Deployment{deployable: deployable, dest: dest}) do
#     IO.puts "Cleaning up... "
#
#     # SecureConnection.ssh(dest.sshuser, dest.sshserver, cmds, true)
#     {:ok, :noop}
#   end
#
#   defp stop_node_if_running(%Deployment{dest: dest, deployable: deployable} = deployment) do
#     IO.puts "Stopping the current node..."
#
#     stpcmds = case stop_cmds() do
#       :default -> """
#         cd #{deployment.dest.path}
#         #{default_stop(deployment)}
#       """
#       cmds -> cmds.(deployment)
#     end
#
#     SecureConnection.ssh(dest.sshuser, dest.sshserver, stpcmds, true)
#   end
#
#   defp publish_to_dest(%Deployment{dest: dest, release: release}) do
#     src = release
#     scp_dest = "#{dest.sshuser}@#{dest.sshserver}:#{dest.path}"
#
#     IO.puts "Copying release from #{release} to #{dest.sshserver}"
#
#     SecureConnection.scp(src, scp_dest, ["-r"])
#   end
#
#   defp prep_node_from_release(deployment) do
#     IO.puts "Preparing node from release..."
#
#     prepcmds = case prep_cmds() do
#       :default -> """
#         cd #{deployment.dest.path}
#         #{default_prep(deployment)}
#       """
#       cmds -> cmds.(deployment)
#     end
#
#     SecureConnection.ssh(deployment.dest.sshuser, deployment.dest.sshserver, prepcmds, true)
#   end
#
#   defp start_node(deployment) do
#     IO.puts "Starting the node..."
#
#     startcmds = case start_cmds() do
#       :default -> """
#         cd #{deployment.dest.path}
#         #{default_start(deployment)}
#       """
#       cmds -> cmds.(deployment)
#     end
#
#     SecureConnection.ssh(deployment.dest.sshuser, deployment.dest.sshserver, startcmds, true)
#   end
#
#   defp default_start(deployment) do
#     app_name = deployment.deployable |> Atom.to_string()
#     """
#     bin/#{app_name} start
#     """
#   end
#
#   #TODO make cookie generation dynamic
#   defp default_prep(deployment) do
#     app_name = deployment.deployable |> Atom.to_string()
#
#     """
#     tar xfz #{app_name}.tar.gz -C .
#
#     rm releases/#{Mix.Project.config[:version]}/vm.args
#     cat > releases/#{Mix.Project.config[:version]}/vm.args <<-END
# ## Name of the node
# -name #{app_name}_#{deployment.env}@127.0.0.1
#
# ## Cookie for distributed erlang
# -setcookie do4Goothoo2bii7aiPhi8Cahhithathaihemiengae8lahchoov2aeBae4ier6du
#
# ## Heartbeat management; auto-restarts VM if it dies or becomes unresponsive
# ## (Disabled by default..use with caution!)
# ##-heart
#
# ## Enable kernel poll and a few async threads
# ##+K true
# ##+A 5
#
# ## Increase number of concurrent ports/sockets
# ##-env ERL_MAX_PORTS 4096
#
# ## Tweak GC to run more often
# ##-env ERL_FULLSWEEP_AFTER 10
#
# # Enable SMP automatically based on availability
# -smp auto
# END
#     """
#   end
#
#   defp default_stop(deployment) do
#     deployable = deployment.deployable
#
#     """
#     rm #{deployable}.tar.gz
#     bin/#{deployable} stop
#     rm * -rf
#     """
#   end
#
#
#   @doc """
#   `:prep_cmds` can be set as a runtime config
#   in the `config.exs` file
#
#   ## Examples
#
#       iex> Akd.Publisher.RemoteSSH.prep_cmds()
#       :default
#   """
#   @spec prep_cmds() :: String.t | :default
#   defp prep_cmds() do
#     config(:prep_cmds, :default)
#   end
#
#
#   @doc """
#   `:start_cmds` can be set as a runtime config
#   in the `config.exs` file
#
#   ## Examples
#
#       iex> Akd.Publisher.RemoteSSH.start_cmds()
#       :default
#   """
#   @spec start_cmds() :: String.t | :default
#   defp start_cmds() do
#     config(:start_cmds, :default)
#   end
#
#
#   @doc """
#   `:stop_cmds` can be set as a runtime config
#   in the `config.exs` file
#
#   ## Examples
#
#       iex> Akd.Publisher.RemoteSSH.stop_cmds()
#       :default
#   """
#   @spec stop_cmds() :: String.t | :default
#   defp stop_cmds() do
#     config(:stop_cmds, :default)
#   end
#
#
#   @doc """
#   Gets configuration assocaited with the `akd` app.
#
#   ## Examples
#   when no config is set, if returns []
#       iex> Akd.Publisher.RemoteSSH.config
#       []
#   """
#   @spec config() :: list
#   defp config do
#     Application.get_env(:akd, Akd.Publisher.RemoteSSH, [])
#   end
#
#
#   @doc """
#   Gets configuration set for a `key`, assocaited with the `akd` app.
#
#   ## Examples
#   when no config is set for `key`, if returns `default`
#       iex> Akd.Publisher.RemoteSSH.config(:random, "default")
#       "default"
#   """
#   @spec config(atom, any) :: any
#   defp config(key, default \\ nil) do
#     config()
#     |> Keyword.get(key, default)
#     |> resolve_config(default)
#   end
#
#
#   @doc """
#   `resolve_config` returns a `system` variable set up with `var_name` key
#    or returns the specified `default` value. Takes in `arg` whose first element is
#    an atom `:system`.
#
#   ## Examples
#   Returns value corresponding to a system variable config or returns the `default` value:
#       iex> Akd.Publisher.RemoteSSH.resolve_config({:system, "SOME_RANDOM_CONFIG"}, "default")
#       "default"
#   """
#   @spec resolve_config(Tuple.t, term) :: term
#   defp resolve_config({:system, var_name}, default) do
#     System.get_env(var_name) || default
#   end
#   defp resolve_config(value, _default), do: value
end

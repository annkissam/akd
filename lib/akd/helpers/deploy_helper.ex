defmodule Akd.DeployHelper do
  @moduledoc """
  This module defines helper functions used to initialize, add hooks to, and
  execute a deployment.
  """

  alias Akd.{Destination, Deployment, Hook}

  @doc """
  This macro executes a pipeline (set of operations) defined in the current
  module with a set of params that can be used to initialize a `Deployment`
  struct.

  Returns true if the deployment initialized was executed successfully; otherwise, it returns false.

  ## Examples

      iex> defmodule TestAkdDeployHelperExecute do
      ...>   import Akd.DeployHelper
      ...>   def pip(), do: []
      ...>   def run() do
      ...>     execute :pip, with: %{name: "node", build_at: {:local, "."},
      ...>       mix_env: "prod", publish_to: "user@host:~/path/to/dir", vsn: "0.1.0"}
      ...>   end
      ...> end
      iex> TestAkdDeployHelperExecute.run()
      true
  """
  defmacro execute(pipeline, with: block) do
    quote do
      deployment = init_deployment(unquote(block))

      __MODULE__
      |> apply(unquote(pipeline), [])
      |> Enum.reduce(deployment, &add_hook(&2, &1))
      |> exec()
    end
  end

  @doc """
  Executes a Deployment. If there's a `failure`, it executes `rollbacks/1` for
  all the `called_hooks`.

  Executes `ensure/1` for all the `called_hooks`

  Returns true if the deployment was executed successfully; otherwise, it returns false.

  ## Examples

      iex> deployment = %Akd.Deployment{mix_env: "prod",
      ...> build_at: Akd.Destination.local("."),
      ...> publish_to: Akd.Destination.local("."),
      ...> name: "name",
      ...> vsn: "0.1.1"}
      iex> Akd.DeployHelper.exec(deployment)
      true
  """
  def exec(%Deployment{hooks: hooks}) do
    {failure, called_hooks} = Enum.reduce(hooks, {false, []}, &failure_and_hooks/2)

    Enum.each(called_hooks, &Hook.ensure/1)

    if failure, do: Enum.each(called_hooks, &Hook.rollback/1)

    !failure
  end

  @doc """
  Initializes a `Akd.Deployment` struct with given params and sanitizes it.

  ## Examples

  When no hooks are given:

      iex> params = %{mix_env: "prod",
      ...> build_at: Akd.Destination.local("."),
      ...> publish_to: Akd.Destination.local("."),
      ...> name: "name",
      ...> vsn: "0.1.1"}
      iex> Akd.DeployHelper.init_deployment(params)
      %Akd.Deployment{build_at: %Akd.Destination{host: :local, path: ".",
          user: :current}, hooks: [], mix_env: "prod", name: "name",
           publish_to: %Akd.Destination{host: :local, path: ".",
                  user: :current}, vsn: "0.1.1"}

  When hooks are given:

      iex> params = %{mix_env: "prod",
      ...> build_at: Akd.Destination.local("."),
      ...> publish_to: Akd.Destination.local("."),
      ...> name: "name",
      ...> vsn: "0.1.1", hooks: [%Akd.Hook{}]}
      iex> Akd.DeployHelper.init_deployment(params)
      %Akd.Deployment{build_at: %Akd.Destination{host: :local, path: ".",
        user: :current}, hooks: [%Akd.Hook{}], mix_env: "prod", name: "name",
           publish_to: %Akd.Destination{host: :local, path: ".",
                  user: :current}, vsn: "0.1.1"}

  When `build_at` and `publish_to` are strings in the form: user@host:path

      iex> params = %{mix_env: "prod",
      ...> build_at: "root@host:~/path",
      ...> publish_to: "root@host:~/path",
      ...> name: "name",
      ...> vsn: "0.1.1"}
      iex> Akd.DeployHelper.init_deployment(params)
      %Akd.Deployment{build_at: %Akd.Destination{host: "host",
        path: "~/path", user: "root"}, hooks: [], mix_env: "prod",
        name: "name",
        publish_to: %Akd.Destination{host: "host", path: "~/path",
        user: "root"}, vsn: "0.1.1"}

  When `build_at` and `publish_to` are strings, not in the form: user@host:path

      iex> params = %{mix_env: "prod",
      ...> build_at: "some-random-string",
      ...> publish_to: "some-random-string",
      ...> name: "name",
      ...> vsn: "0.1.1"}
      iex> Akd.DeployHelper.init_deployment(params)
      ** (MatchError) no match of right hand side value: ["some-random-string"]

  """
  def init_deployment(params) do
    Deployment
    |> struct!(params)
    |> sanitize()
  end

  @doc """
  Adds a hook or hooks to deployment struct's hooks and returns the updated
  Deployment.t

  This function takes in a Deployment and `hook` variable.

  `hook` variable can be an `Akd.Hook.t` struct or a tuple (with one element
  specifying type of hook/module and other opts)

  ## Examples
  When a deployment and a `Hook.t` is given.

      iex> deployment = %Akd.Deployment{mix_env: "prod",
      ...> build_at: Akd.Destination.local("."),
      ...> publish_to: Akd.Destination.local("."),
      ...> name: "name",
      ...> vsn: "0.1.1"}
      iex> Akd.DeployHelper.add_hook(deployment, %Akd.Hook{})
      %Akd.Deployment{build_at: %Akd.Destination{host: :local, path: ".",
            user: :current},
           hooks: [%Akd.Hook{ensure: [], ignore_failure: false, main: [],
           rollback: [], run_ensure: true}], mix_env: "prod", name: "name",
           publish_to: %Akd.Destination{host: :local, path: ".",
                        user: :current}, vsn: "0.1.1"}

  When a deployment and a tuple is given, and the first element of tuple
  is a `Hook.t`

      iex> deployment = %Akd.Deployment{mix_env: "prod",
      ...> build_at: Akd.Destination.local("."),
      ...> publish_to: Akd.Destination.local("."),
      ...> name: "name",
      ...> vsn: "0.1.1"}
      iex> Akd.DeployHelper.add_hook(deployment, {%Akd.Hook{}, []})
      %Akd.Deployment{build_at: %Akd.Destination{host: :local, path: ".",
            user: :current},
           hooks: [%Akd.Hook{ensure: [], ignore_failure: false, main: [],
           rollback: [], run_ensure: true}], mix_env: "prod", name: "name",
           publish_to: %Akd.Destination{host: :local, path: ".",
                        user: :current}, vsn: "0.1.1"}

  When a deployment and a tuple is given, and the first element of tuple
  is a Hook Module

      iex> deployment = %Akd.Deployment{mix_env: "prod",
      ...> build_at: Akd.Destination.local("."),
      ...> publish_to: Akd.Destination.local("."),
      ...> name: "name",
      ...> vsn: "0.1.1"}
      iex> Akd.DeployHelper.add_hook(deployment, {Akd.Init.Release, []})
      %Akd.Deployment{build_at: %Akd.Destination{host: :local, path: ".",
          user: :current},
         hooks: [%Akd.Hook{ensure: [
            %Akd.Operation{cmd: "rm -rf _build/prod", cmd_envs: [],
             destination: %Akd.Destination{host: :local, path: ".",
            user: :current}}], ignore_failure: false,
            main: [%Akd.Operation{cmd: "mix deps.get \\n mix compile",
            cmd_envs: [{"MIX_ENV", "prod"}],
            destination: %Akd.Destination{host: :local, path: ".",
                   user: :current}},
             %Akd.Operation{cmd: "mix release.init",
                   cmd_envs: [{"MIX_ENV", "prod"}],
                   destination: %Akd.Destination{host: :local, path: ".",
                    user: :current}}], rollback: [], run_ensure: true}],
                            mix_env: "prod", name: "name",
                            publish_to: %Akd.Destination{host: :local, path: ".",
                                         user: :current}, vsn: "0.1.1"}
  """
  @spec add_hook(Deployment.t(), Hook.t() | tuple()) :: Deployment.t()
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

  # This function takes in a hook, calls it's main operations and
  # adds it to called hooks. If a hook fails, it sets failure to false, which
  # prevents this function from calling main operations further.
  defp failure_and_hooks(hook, {failure, called_hooks}) do
    with false <- failure,
         {:ok, _output} <- Hook.main(hook) do
      {failure, [hook | called_hooks]}
    else
      {:error, _err} ->
        {!hook.ignore_failure, called_hooks}

      true ->
        {true, called_hooks}
    end
  end

  # Get hooks associated with a Module
  defp get_hooks(d, mod, opts), do: apply(mod, :get_hooks, [d, opts])

  # Sanitizes Deployment's build_at and publish_to destinations
  defp sanitize(%Deployment{build_at: b, publish_to: p} = deployment) do
    %Deployment{deployment | build_at: to_dest(b), publish_to: to_dest(p)}
  end

  # Converts a string or a tuple to a Destination struct.
  defp to_dest({:local, path}), do: Destination.local(path)
  defp to_dest(d) when is_binary(d), do: Destination.parse(d)
  defp to_dest(%Destination{} = d), do: d
end

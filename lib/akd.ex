defmodule Akd do
  @moduledoc """
  A framework that makes elixir deployments a breeze. It's highly configurable,
  yet easy to set up.

  Although Akd is mainly written for deploying elixir apps, it can be used
  for any server automation process or deploying non-elixir apps.

  Akd comes with DSL which make writing automated deployments much simpler, and
  mix tasks with generators which allow the use of that DSL easier.

  Akd, by default, has multiple phases for deploying an application:

  - `fetch`: This is where `akd` attempts to fetch the source-code which
    corresponds to a release (deployed app). This can be done by using `git`,
    `svn` or just `scp`.

  - `init`: In this phase `akd` initializes and configures the libraries
    required for the rest of the deployment process. For an elixir app, it can
    be configuring `distillery` or `docker`.

  - `build`: In this phase `akd` produces a deployable entity. It can be a
    binary produced by distillery or source code itself or even a docker image.

  - `publish`: In this phase `akd` publishes/deploys the app to the desired
    destination. This can be done by `scp`, `cp` etc.

  - `stop`: In this phase `akd` stops a previously running instance of the
    app. (This is not required for zero downtime apps)

  - `start`: In this phase `akd` starts a newly deployed instance of the app.

  Each of these phases accomplish what they do through `Akd.Hook` and
  `Akd.Dsl.FormHook`.
  """

  @doc """
  `:fetch` can be set as a runtime config
  in the `config.exs` file

  ## Examples
  when no `fetch` config is set, it returns `Akd.Fetch.Git`
      iex> Akd.fetch
      Akd.Fetch.Git
  """
  def fetch do
    config(:fetch, Akd.Fetch.Git)
  end

  @doc """
  `:init` can be set as a runtime config
  in the `config.exs` file

  ## Examples
  when no `init` config is set, it returns `Akd.Init.Distillery`
      iex> Akd.init
      Akd.Init.Distillery
  """
  def init do
    config(:init, Akd.Init.Distillery)
  end

  @doc """
  `:build` can be set as a runtime config
  in the `config.exs` file

  ## Examples
  when no `build` config is set, it returns `Akd.Build.Distillery`
      iex> Akd.build
      Akd.Build.Distillery
  """
  def build do
    config(:build, Akd.Build.Distillery)
  end

  @doc """
  `:publish` can be set as a runtime config
  in the `config.exs` file

  ## Examples
  when no `publish` config is set, it returns `Akd.Publish.Distillery`
      iex> Akd.publish
      Akd.Publish.Distillery
  """
  def publish do
    config(:publish, Akd.Publish.Distillery)
  end

  @doc """
  `:start` can be set as a runtime config
  in the `config.exs` file

  ## Examples
  when no `start` config is set, it returns `Akd.Start.Distillery`
      iex> Akd.start
      Akd.Start.Distillery
  """
  def start do
    config(:start, Akd.Start.Distillery)
  end

  @doc """
  `:stop` can be set as a runtime config
  in the `config.exs` file

  ## Examples
  when no `stop` config is set, it returns `Akd.Stop.Distillery`
      iex> Akd.stop
      Akd.Stop.Distillery
  """
  def stop do
    config(:stop, Akd.Stop.Distillery)
  end

  @doc """
  Gets configuration assocaited with the `akd` app.

  ## Examples
  when no config is set, it returns []
      iex> Akd.config
      []
  """
  @spec config() :: Keyword.t()
  defp config() do
    Application.get_env(:akd, Akd, [])
  end

  @doc """
  Gets configuration set for a `key`, assocaited with the `akd` app.

  ## Examples
  when no config is set for `key`, it returns `default`
      iex> Akd.config(:random, "default")
      "default"
  """
  @spec config(Atom.t(), term) :: term
  defp config(key, default \\ nil) do
    config()
    |> Keyword.get(key, default)
    |> resolve_config(default)
  end

  @doc """
  `resolve_config` returns a `system` variable set up with `var_name` key
   or returns the specified `default` value. Takes in `arg` whose first element is
   an atom `:system`.

  ## Examples
  Returns value corresponding to a system variable config or returns the `default` value:
      iex> Akd.resolve_config({:system, "SOME_RANDOM_CONFIG"}, "default")
      "default"
      iex> Akd.resolve_config("value", "default")
      "value"
  """
  @deprecated """
  `{:system, var_name}` is deprecated. If you need to use a System variable in
  the run-time, I would be explicit about what Hooks to use in the main call
  instead of configuring it.

  Read this article for more details: http://michal.muskala.eu/2017/07/30/configuring-elixir-libraries.html
  """
  @spec resolve_config(Tuple.t(), term) :: term
  defp resolve_config({:system, var_name}, default) do
    System.get_env(var_name) || default
  end
  defp resolve_config(value, _default), do: value
end

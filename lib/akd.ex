defmodule Akd do
  @moduledoc """
  A framework that makes elixir deployments a breeze. It's highly configurable,
  yet easy to set up.


  ## Example Configuration (dev.exs)(Optional):


  ## Example Configuration (test.exs)(Optional):


  """

  @doc """
  `:fetch` can be set as a runtime config
  in the `config.exs` file

  ## Examples
  when no `fetch` config is set, if returns `Akd.Fetch.Git`
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
  when no `init` config is set, if returns `Akd.Init.Distillery`
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
  when no `build` config is set, if returns `Akd.Build.Distillery`
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
  when no `publish` config is set, if returns `Akd.Publish.Distillery`
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
  when no `start` config is set, if returns `Akd.Start.Distillery`
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
  when no `stop` config is set, if returns `Akd.Stop.Distillery`
      iex> Akd.stop
      Akd.Stop.Distillery
  """
  def stop do
    config(:stop, Akd.Stop.Distillery)
  end


  @doc """
  Gets configuration assocaited with the `akd` app.

  ## Examples
  when no config is set, if returns []
      iex> Akd.config
      []
  """
  def config do
    Application.get_env(:akd, Akd, [])
  end


  @doc """
  Gets configuration set for a `key`, assocaited with the `akd` app.

  ## Examples
  when no config is set for `key`, if returns `default`
      iex> Akd.config(:random, "default")
      "default"
  """
  def config(key, default \\ nil) do
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
  """
  @spec resolve_config(Tuple.t, term) :: {term}
  def resolve_config({:system, var_name}, default) do
    System.get_env(var_name) || default
  end
  def resolve_config(value, _default), do: value
end

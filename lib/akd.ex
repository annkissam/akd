defmodule Akd do
  @moduledoc """
  A framework that makes elixir deployments a breeze. It's highly configurable,
  yet easy to set up.


  ## Example Configuration (dev.exs)(Optional):


  ## Example Configuration (test.exs)(Optional):


  """

  @doc """
  `:fetcher` can be set as a runtime config
  in the `config.exs` file

  ## Examples
  when no `fetcher` config is set, if returns `Akd.Fetcher.Git`
      iex> Akd.fetcher
      Akd.Fetcher.Test
  """
  def fetcher do
    config(:fetcher, Akd.Fetcher.Git)
  end


  @doc """
  `:initer` can be set as a runtime config
  in the `config.exs` file

  ## Examples
  when no `initer` config is set, if returns `Akd.Initer.Distillery`
      iex> Akd.initer
      Akd.Initer.Test
  """
  def initer do
    config(:initer, Akd.Initer.Distillery)
  end


  @doc """
  `:builder` can be set as a runtime config
  in the `config.exs` file

  ## Examples
  when no `builder` config is set, if returns `Akd.Builder.Distillery`
      iex> Akd.builder
      Akd.Builder.Test
  """
  def builder do
    config(:builder, Akd.Builder.Distillery)
  end

  @doc """
  `:publisher` can be set as a runtime config
  in the `config.exs` file

  ## Examples
  when no `publisher` config is set, if returns `Akd.Publisher.Distillery`
      iex> Akd.publisher
      Akd.Publisher.Test
  """
  def publisher do
    config(:publisher, Akd.Publisher.Distillery)
  end


  @doc """
  Gets configuration assocaited with the `akd` app.

  ## Examples
  when no config is set, if returns []
      iex> Akd.config
      [fetcher: Akd.Fetcher.Test, initer: Akd.Initer.Test, builder: Akd.Builder.Test, publisher: Akd.Publisher.Test]
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

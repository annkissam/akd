defmodule Akd.Mixfile do
  use Mix.Project

  @version "0.2-rc"
  @url "https://github.com/annkissam/akd"

  def project do
    [
      app: :akd,
      version: @version,
      elixir: "~> 1.4",
      deps: deps(),
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,

      # Test
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test],
      aliases: aliases(),
      elixirc_paths: elixirc_paths(Mix.env),

      # Hex
      description: description(),
      package: package(),

      # Docs
      name: "Akd",
      docs: docs(),
    ]
  end

  def application do
    [applications: [:logger]]
  end

  def package do
    [
      files: ["lib", "mix.exs", "README.md"],
      maintainers: ["Adi Iyengar"],
      licenses: ["MIT"],
      links: %{"Github" => @url},
    ]
  end

  defp deps do
    [
      {:credo, "~> 0.5", only: [:dev, :test]},
      {:distillery, "~> 1.5", runtime: false, optional: true},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false},
      {:excoveralls, "~> 0.3", only: :test},
      {:inch_ex, "~> 0.5", only: [:dev, :test, :docs]},
      {:simple_docker, "~> 0.1.0", runtime: false, optional: true},
    ]
  end

  defp description do
    """
    An configurable (but easy to set up) Elixir Deployment Automation library.
    """
  end

  def docs do
    [
      main: "Akd",
      extras: [],
      source_url: @url,
      source_ref: "v#{@version}"
    ]
  end

  defp aliases do
    []
  end

  defp elixirc_paths(:test), do: ["lib", "priv", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]
end

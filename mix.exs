defmodule Akd.Mixfile do
  use Mix.Project

  @version "0.2.1"
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
      preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test],
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
      {:excoveralls, "~> 0.8", only: [:dev, :test]},
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
      extras: ["docs/Nomenclature.md",
               "docs/DeploymentStrategies.md",
               "docs/Walkthrough.md",
               "docs/CustomHooks.md",
               "docs/UsingGenerators.md"],
      source_url: @url,
      source_ref: "v#{@version}"
    ]
  end

  defp aliases do
    ["publish": ["hex.publish", &git_tag/1]]
  end

  defp git_tag(_args) do
    System.cmd "git", ["tag", "v" <> Mix.Project.config[:version]]
    System.cmd "git", ["push", "--tags"]
  end

  defp elixirc_paths(:test), do: ["lib", "priv", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]
end

defmodule Mix.Tasks.Akd.Deploy do
  @moduledoc """
  This task was generated by Akd

  TODO: Add more documentation
  """

  use Akd.Mix.Task

  # This tasks comes with the following switches, but add more if needed
  # For example: :client (for your apps)
  @switches [name: :string, build_at: :string, env: :string,
              publish_to: :string, vsn: :string]

  @aliases [n: :name, b: :build_at, e: :env, p: :publish_to, v: :vsn]

  # Change default values for all the switches
  @defaults [name: "node", build_at: {:local, "."}, env: "prod",
             publish_to: "user@host:~/path/to/dir",
             vsn: Mix.Project.config[:version]]

  pipeline :fetch do
    hook Akd.Fetch.Git
  end

  pipeline :init do
    hook Akd.Init.Distillery
  end

  pipeline :build do
    hook Akd.Build.Distillery

    hook Akd.Build.Phoenix.Npm,
      package: "path/to/assets_folder", # web_app/assets
      cmd_envs: [] # Add build time system variables

    hook Akd.Build.Phoenix.Brunch,
      config: "path/to/assets_folder", # web_app/assets
      brunch: "./node_modules/brunch/bin/brunch", # Path to brunch from assets folder
      cmd_envs: [] # Add build time system variables
  end

  pipeline :publish do
    hook Akd.Stop.Distillery, ignore_failure: true

    hook Akd.Publish.Distillery
    hook Akd.Start.Distillery
  end

  pipeline :deploy do
    pipe_through :fetch
    pipe_through :init
    pipe_through :build
    pipe_through :publish
  end

  def run(argv) do
    {parsed, _, _} =
      OptionParser.parse(argv, switches: @switches, aliases: @aliases)

    execute :deploy, with: parameterize(parsed)
  end

  # This functions translates a list options into parameters that can be
  # converted to a Akd.Deployment struct
  def parameterize(opts) do
    opts = uniq_merge(opts, @defaults)

    %{mix_env: opts[:env], build_at: opts[:build_at], hooks: [],
      publish_to: opts[:publish_to], name: opts[:name], vsn: opts[:vsn]}
  end

  # This function takes two keyword lists and merges them keeping the keys
  # unique. If there are multiple values for a key, it takes the value from
  # the first value of keyword1 corresponding to that key.
  defp uniq_merge(keyword1, keyword2) do
    keyword2
    |> Keyword.merge(keyword1)
    |> Keyword.new()
  end
end
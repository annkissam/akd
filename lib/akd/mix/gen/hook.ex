defmodule Mix.Tasks.Akd.Gen.Hook do
  @shortdoc ~w(Generates an Akd.Hook which can be used to run commands on a deployment)

  @tsk ~s(mix akd.gen.hook)

  @info """
  #{@tsk} expects only module name:
      $ `@{tsk} HookModule`

  Usage:
      $ `@{tsk} Deploy`

  """

  @moduledoc """
  This task generates a hook module which can be used to run commands on
  a `Akd.Deployment.t` struct.

  Please refer to `Akd.Hook` for more details.

  ## Info:

  #{@info}
  """

  use Mix.Task

  @switches [
    fetcher: :string,
    initer: :string,
    builder: :string,
    publisher: :string,
    with_phx: :boolean
  ]

  @aliases [f: :fetcher, i: :initer, b: :builder, p: :publisher, w: :with_phx]

  @errs %{
    umbrella: "task `#{@tsk}` can only be run inside an application directory",
    hook: "hook already exists. Please pick a new name",
    args: "Invalid arguments"
  }

  @doc """
  Runs the mix hook to generate the hook module.
  """
  def run(args) do
    if Mix.Project.umbrella?(), do: info_raise(@errs.umbrella)

    generate(args)
  end

  # Generates the hook module with args
  defp generate(args) do
    {hook_opts, parsed, _} = OptionParser.parse(args, switches: @switches, aliases: @aliases)

    parsed
    |> validate_parsed!()
    |> Akd.Generator.Hook.gen(hook_opts)
  end

  # Validates parsed arguments, expects there to be a name
  defp validate_parsed!([name | tail]) do
    mod = name
    if Enum.member?(Mix.Task.load_all(), mod), do: info_raise(@errs.hook)
    [mod | tail]
  end

  # Raise error if no name is given
  defp validate_parsed!(_) do
    info_raise(@errs.args)
  end

  # Raise with info
  defp info_raise(message) do
    Mix.raise("""
    #{message}

    #{@info}
    """)
  end
end

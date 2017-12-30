defmodule Mix.Tasks.Akd.Gen.Task do
  @shortdoc ~w(Generates an Akd.Mix.Task which can be used to deploy an app)

  @tsk ~s(mix akd.gen.task)

  @info """
  #{@tsk} expects both module name and optional parameters:
      $ `@{tsk} TaskModule -f FetcherModule`

  Usage:
      $ `@{tsk} Deploy -f Akd.Fetcher.Git`


  Options:

  Option         Alias        Description
  --------------------------------------------------------------------------

  --fetcher       -f      Expects a fetcher hook module.
                          Defaults to `Akd.Fetcher.Git`.
                          Native Fetchers include:
                          `Akd.Fetcher.Git` and `Akd.Fetcher.Scp`

  --initer        -i      Expects an initer hook module.
                          Defaults to `Akd.Initer.Distillery`.
                          Native Fetchers include:
                          `Akd.Fetcher.Distillery`

  --builder       -b      Expects a builder hook module.
                          Defaults to `Akd.Builder.Distillery`.
                          Native Fetchers include:
                          `Akd.Builder.Distillery` and `Akd.Builder.Docker`

  --publisher     -p      Expects a publisher hook module.
                          Defaults to `Akd.Initer.Distillery`.
                          Native Fetchers include:
                          `Akd.Publisher.Distillery` and `Akd.Publisher.Docker`

  --with_phx      -w     Generates phoenix hooks alongside base books

  """

  @moduledoc """
  This task generates a mix task which can be used to deploy an app.

  Please refer to `Akd.Mix.Task` for more details.

  ## Info:

  #{@info}
  """

  use Mix.Task

  @switches [fetcher: :string, initer: :string,
             builder: :string, publisher: :string, with_phx: :boolean]

  @aliases [f: :fetcher, i: :initer,
            b: :builder, p: :publisher, w: :with_phx]

  @errs %{
    umbrella: "task `#{@tsk}` can only be run inside an application directory",
    task: "task already exists. Please pick a new name",
    args: "Invalid arguments"
  }

  @doc """
  Runs the mix task to generate the task module.
  """
  def run(args) do
    if Mix.Project.umbrella?(), do: info_raise @errs.umbrella

    generate(args)
  end

  # Generates the task module with args
  defp generate(args) do
    {task_opts, parsed, _} =
      OptionParser.parse(args, switches: @switches, aliases: @aliases)

    parsed
    |> validate_parsed!()
    |> Akd.Generator.Task.gen(task_opts)
  end

  # Validates parsed arguments, expects there to be a name
  defp validate_parsed!([name | tail]) do
    mod = "Mix.Tasks.Akd." <> name
    if Enum.member?(Mix.Task.load_all(), mod), do: info_raise @errs.task
    [mod | tail]
  end

  # Raise error if no name is given
  defp validate_parsed!(_) do
    info_raise @errs.args
  end

  # Raise with info
  defp info_raise(message) do
    Mix.raise """
    #{message}

    #{@info}
    """
  end
end

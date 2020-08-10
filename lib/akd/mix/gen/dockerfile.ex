defmodule Mix.Tasks.Akd.Gen.Dockerfile do
  @shortdoc ~w(Generates a Dockerfile which can be used to run commands on a deployment)

  @tsk ~s(mix akd.gen.dockerfile)

  @info """
  #{@tsk} expects a filename, type, os, osversion and other options:
      $ `@{tsk} --type <type> --os <os> --osversion <osversion> <filename>`

  Usage:
      $ `@{tsk} --type base --os centos --osversion 7 Dockerfile`

  Options:

  Option         Alias        Description
  --------------------------------------------------------------------------

  --type           -t         Type of Dockerfile
                              Can be either `build` ot `base`

  --path           -p         Path to where the dockerfile will be created.


  OPTIONS ONLY FOR BASE DOCKERFILES:

  --os          NO-ALIAS      OS for which Dockerfile should be generated.
                              Currently, there's support for `centos` and `ubuntu`

  --osversion   NO-ALIAS      Version of OS


  --nodejs      NO-ALIAS      NodeJS version to be installed on base image.
                              This switch is only for `base` build.

  --elixir      NO-ALIAS      Elixir version to be installed on base image.
                              This switch is only for `base` build.

  --erlang      NO-ALIAS      Erlang version to be installed on base image.
                              This switch is only for `base` build.

  --asdf        NO-ALIAS      Asdf version to be used to install elixir and erlang


  OPTIONS ONLY FOR BUILD DOCKERFILES:

  --base          -b          Name of the base image on top of which build will
                              happen. This can be done by running `docker build`
                              for `base` Dockerfile with a flag `-t`

  --cleanup     NO-ALIAS      Specifies whether to do the cleanup on the
                              build image. This removes the app code and just
                              keeps the built release.

  --phxapps     NO-ALIAS      Accumulates all the phoenix app paths in the release.

  --envs          -e          Accumulates all the environment variables that
                              need to be defined while building through
                              distillery.

  --mixenv      NO-ALIAS      Specifies the mix environment to be set while
                              while building the release

  --nodename       -n         Specifies the desired name of the release.

  --cmd         NO-ALIAS      This corresponds the the command that will be ran
                              on the entry point of Docker container

  """

  @moduledoc """
    This task generates a dockerfile module which can be used to run commands on
  a `Akd.Deployment.t` struct.

  ## Info:

  #{@info}
  """

  use Mix.Task

  @switches [
    type: :string,
    os: :string,
    osversion: :string,
    nodejs: :string,
    elixir: :string,
    erlang: :string,
    asdf: :string,
    base: :string,
    cleanup: :string,
    phxapps: :keep,
    envs: :keep,
    mixenv: :string,
    nodename: :string,
    path: :string,
    cmd: :string
  ]

  @aliases [type: :t, base: :b, envs: :e, nodename: :n, path: :p]

  @defaults [
    type: "base",
    os: "centos",
    osversion: "7",
    nodejs: "5.1.0",
    erlang: "20.0",
    elixir: "1.4.5",
    mixenv: "prod",
    cleanup: "true",
    asdf: "0.4.1",
    path: "./",
    cmd: "start"
  ]

  @errs %{
    umbrella: "task `#{@tsk}` can only be run inside an application directory"
  }

  @doc """
  Runs the mix dockerfile to generate the dockerfile module.
  """
  def run(args) do
    if Mix.Project.umbrella?(), do: info_raise(@errs.umbrella)

    generate(args)
  end

  # Generates the dockerfile module with args
  defp generate(args) do
    {dockerfile_opts, parsed, _} =
      OptionParser.parse(args, switches: @switches, aliases: @aliases)

    parsed
    |> validate_parsed!()
    |> Akd.Generator.Dockerfile.gen(uniq_merge(dockerfile_opts, @defaults))
  end

  # Validates parsed arguments, expects there to be a name
  defp validate_parsed!([name | tail]) do
    mod = name
    [mod | tail]
  end

  # Raise error if no name is given
  defp validate_parsed!(_) do
    info_raise("No name given")
  end

  # Raise with info
  defp info_raise(message) do
    Mix.raise("""
    #{message}

    #{@info}
    """)
  end

  # This function takes two keyword lists and merges them keeping the keys
  # unique. If there are multiple values for a key, it takes the value from
  # the first value of keyword1 corresponding to that key.
  defp uniq_merge(keyword1, keyword2) do
    keyword2
    |> Keyword.merge(keyword1)
  end
end

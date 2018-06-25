# Using Akd to solve Build-time vs Run-time Environment problem

Deploying Elixir applications can be hard to figure out, with multiple strategies
involving tools like `distillery`, `docker`, `edeliver` or `mix` to choose from.
At Annkissam, we have adopted a simple workflow for deploying Elixir applications,
which we would like to share with the community.

This post digs deeper into `akd` while explaining how we at Annkissam use `akd`
to simplify one of the most prevalent Elixir deployment problems.

## Prelude

At Annkissam, we use `akd` with `distillery` to deploy OTP releases. We run them
mostly on CentOS servers. We typically have a build server (also CentOS) on which
we run the `Distillery` release task and copy the built release to a final
destination on which the app is started.

There are several pain-points which we have recognized when deploying
Elixir applications as releases. In this post, we will talk about one of those
pain-points and how `akd` provides a solution for it.

## Build-time vs Run-time Environment variables

There aren't many differneces between the run-time and build-time environment when
running a Mix project in dev environment. However, while using releases, they are
often the biggest hurdles that we encounter.

While building releases, we have access to the `Mix.Config` of the project. This
allows us to access the environment variables during compile (build) time using
`System.get_env/1`. However, once built the value of `System.get_env` cannot be
changed in the configuration. There are several ways of overcoming this.
`distillery` provides `REPLACE_OS_VARS` config which loads from environments
from the destination server, `load_from_system_env` approach in `phoenix` loads
environments lazily at run-time, or a tool like
[`conform`](https://github.com/bitwalker/conform) that allows for an app to
adapt to its environment. `Akd` provides it's own simple solution to this
problem, which works for most of our applications.

### Providing Environments Before Builds

`Akd` allows us to specify environment variables to `Hook` calls. At Annkissam,
we use this feature to provide build-time environment variables which can be
used to build a release.

Once, you have generated an `akd` task, we can configure it to add environment
variables. `Akd.Build.Distillery` accepts `cmd_envs` as a list of `Tuple`s:

_For more information on how to generate an akd task, check
[the documentation](https://hexdocs.pm/akd/Mix.Tasks.Akd.Gen.Task.html) or
the [Walkthrough](https://www.annkissam.com/technology/Elixir)_

```elixir
# in the deploy task

pipeline :build do
  hook Akd.Build.Distillery,
    run_ensure: false,
    cmd_env: [{"SOME_ENV", "some_value"}]
end

```

Doing this builds the `distillery` release with an environment variable,
`SOME_ENV` with value `"some_value"`.

Similarly, we can pass run-time environments to the publish hook,
`Akd.Publish.Distillery` call:

```elixir
# in the deploy task

pipeline :publish do
  hook Akd.Stop.Distillery, ignore_failure: true

  hook Akd.Publish.Distillery, scp_options: "-o \"ForwardAgent yes\""

  hook Akd.Start.Distillery,
    cmd_env: [{"ECTO_DB_URL", "ecto://user:password@127.0.0.1/database"}]
end
```

This approach is particularly useful as it doesn't export environment variables,
but just calls the command within the context of a given specification of
environment variable values. This means our deploys are not changing the
environment of the `publish` server. This allows us to deploy and run multiple
instances of the same app on the same server or apps that happen to share the
same environment variable names, without those apps interfering with one
another.

However, there's a small problem with this approach: We need to know the
run-time environments at deploy time (while calling `$ mix akd.deploy`).

In situations where we don't have access to the run-time environments at
deploy-time, we use a different approach.

### The Env Command

Another way to pass run-time environments is to put them in a file inside a
unique folder in the destination server (e.g.
`<path-to-the-release>/support/environment`). This file contains all the
environment variables needed to run a built release.

For example:

```bash
# in support/environment

HOST="localhost"
ECTO_DB_URL="ecto://user:password@127.0.0.1/database"
```

Now, we just have to `cat` the contents of this file and prepend them whenever
we want to run the `start` command of a `distillery` release.

A way to automate that is by writing a custom `distillery` command, `env`.

`Akd.Init.Distillery` hook call accepts a `template` option, which takes a path
to a distillery config's template file. This allows us to customize the use
of `distillery` with `akd`.

We can write a custom template, which specifies a custom command `env`:

```elixir
# in config.ex.exs

~w(rel plugins *.exs)
|> Path.join()
|> Path.wildcard()
|> Enum.map(&Code.eval_file(&1))

use Mix.Releases.Config,
    default_release: :default,
    default_environment: Mix.env()

environment :dev do
  set dev_mode: true
  set include_erts: false
  set cookie: <%= inspect(get_cookie.()) %>
end

environment :prod do
  set include_erts: true
  set include_src: false
  set cookie: <%= inspect(get_cookie.()) %>
end

environment :staging do
  set include_erts: true
  set include_src: false
  set vm_args: "deployer/priv/vm.args.eex"
  set cookie: <%= inspect(get_cookie.()) %>
end

<%= for release <- releases do %><%= if Keyword.get(release, :is_umbrella) do %>
release :<%= Keyword.get(release, :release_name) %> do
  set version: Mix.Project.config[:version]
  set applications: [
    :run-time_tools,
<%= Enum.map(Keyword.get(release, :release_applications), fn {app, start_type} ->
    "    #{app}: :#{start_type}"
    end) |> Enum.join(",\n") %>
  ]
  set commands: [
    env: "commands/env.sh", # Add a custom command named env.
  ]
end<% else %>
release :<%= Keyword.get(release, :release_name) %> do
  set version: current_version(:<%= Keyword.get(release, :release_name)%>)
  set applications: [
    :run-time_tools
  ]
end<% end %>
<% end %>
```

Currently (as of `distillery 1.5`) this is the only way of specifying a custom
command before `init`. For more information on custom command, check out
[this post](https://hexdocs.pm/distillery/custom-commands.html#content).

Now we can create a file `commands/env.sh` which has the following content:

```bash
# in commands/env.sh

env $(cat ./support/environment | xargs) bin/release_name $1
```

This allows us to call `bin/release_name env <command>`. In essence, this
command fetches environment variable values from the `support/environment` file
and (within the context of these values) invokes `<command>`.

Once published, `env` can be used as follows:

`$ bin/release_name env start`

Now, we can generate a custom hook that use the `env` command to start the
released application.

To generate a custom hook run: `$ mix akd.gen.hook Deployer.Hooks.EnvStart`.

_To learn more about custom hook generator, check out
[this page](https://hexdocs.pm/akd/Mix.Tasks.Akd.Gen.Hook.html#content)_

We can replace the generated file's contents with the following:

```elixir
# lib/hooks/env_start.ex

defmodule Deployer.Hooks.EnvStart do
  @moduledoc """
  Custom Start hook for Annkissam's workflow of loading the env variables
  only for the start command.
  """

  use Akd.Hook

  @default_opts [run_ensure: true, ignore_failure: false]

  @doc false
  @spec get_hooks(Akd.Deployment.t, Keyword.t) :: list(Akd.Hook.t)
  def get_hooks(deployment, opts \\ []) do
    opts = uniq_merge(opts, @default_opts)
    [start_hook(deployment, opts)]
  end

  # This function takes a deployment and options and returns an Akd.Hook.t
  # struct using FormHook DSL
  defp start_hook(deployment, opts) do
    destination = Akd.DestinationResolver.resolve(:publish, deployment)
    cmd_env = Keyword.get(opts, :cmd_env, [])

    form_hook opts do
      main "bin/#{deployment.name} env start", destination,
        cmd_env: cmd_env
    end
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
```

This hook allows us to call the `start` command of a `distillery` release with
loaded run-time environments.

Now we can replace `Akd.Start.Distillery` with `Deployer.Hooks.EnvStart` in
out `:publish` pipeline of the `akd` task:

```elixir
# in the deploy task

pipeline :publish do
  hook Akd.Stop.Distillery, ignore_failure: true

  hook Akd.Publish.Distillery, scp_options: "-o \"ForwardAgent yes\""

  hook Deployer.Hooks.EnvStart
end
```

Now, our deployments can use run-time variables without us having to specify them
at deploy-time.

## Conclusion

`Akd` provides two ways of providing run-time configuration to a release:

* By adding `cmd_envs` to the start hook: This is a simpler approach, but
  requires us to specify run-time environments at deploy-time.

* By creating a custom `distillery` command, and a custom `akd` hook which calls
  the command: This is a more complex approach, but it loads the run-time
  environments at publish time without having to provide them at deploy-time.

This was just an example of how `akd` provides solutions to some of the problems
we had with Elixir deployments at Annkissam.

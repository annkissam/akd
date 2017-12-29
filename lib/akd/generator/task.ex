defmodule Akd.Generator.Task do
  @moduledoc """
  This module handles the generation of a custom task which use `Akd.Task`.
  This can either directly be called, or called through a mix task,
  `mix akd.gen.task`.

  This class uses EEx and Mix.Generator to fetch file contents from an eex
  template and populate the interpolated fields, writing it to the speficied
  file.

  ## Usage:

  The following call creates a file `run.ex` at location `path/to/file/run.ex`

  ```
  Akd.Generator.Task.gen(["run.ex"], path: "path/to/file")
  ```
  """

  require EEx
  require Mix.Generator

  @path "lib/"

  # Native hook types that can be added using this genenrator
  @hooks ~w(fetch init build publish start stop)a

  @doc """
  This is the callback implementation for `gen/2`.

  This function takes in a list of inputs and a list of options and generates
  a module that uses `Akd.Task` at the specified path with the specified name.

  The first element of the input is expected to be the name of the file.

  The path can be sent to the `opts`.

  If no path is sent, it defaults to #{@path}

  ## Examples:

    Akd.Generator.Hook.gen(["task.ex"], [path: "some/path"])

  """
  @spec gen(list, Keyword.t) :: :ok | {:error, String.t}
  def gen([name | _], opts) do
    name
    |> validate_and_format_opts(opts)
    |> text_from_template()
    |> write_to_file(name)
  end

  # This function validates the name and options sent to the generator
  # and formats the options making it ready for the template to read from.
  defp validate_and_format_opts(name, opts) do
    opts = @hooks
      |> Enum.reduce(opts, &resolve_hook_opts/2)
      |> Keyword.put_new(:path, @path)
      |> Keyword.put_new(:with_phx, false)

    [{:name, resolve_name(name)} | opts]
  end

  # This function adds the default_hook to a keyword, if the keyword
  # doesn't have key corresponding to the `hook`. Else just returns the keyword
  # itself.
  defp resolve_hook_opts(hook, opts) do
    Keyword.put_new(opts, hook, default_string(hook))
  end

  # This function gets default_hook from `Akd` module based on hook type
  # and converts the module name to string
  defp default_string(hook) do
    Akd
    |> apply(hook, [])
    |> Macro.to_string()
  end

  # This function gets the name of file from the module name
  defp resolve_name(name) do
    Macro.camelize(name)
  end

  # This function gives the location for the template which will be used
  # by the generator
  defp template(), do:  "#{__DIR__}/templates/task.ex.eex"

  # This function takes formatted options and returns a tuple.
  # First element of the tuple is the path to file and second element is
  # the evaluated file string.
  defp text_from_template(opts) do
    {Keyword.get(opts, :path), EEx.eval_file(template(), assigns: opts)}
  end

  # This function writes contents to a file at a specific path
  defp write_to_file({path, code}, name) do
    path = path <> Macro.underscore(name) <> ".ex"

    case File.exists?(path) do
      true -> {:error, "File #{path} already exists."}
      _ -> Mix.Generator.create_file(path, code)
    end
  end
end

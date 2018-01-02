defmodule Akd.Generator.Dockerfile do
  @moduledoc """
  This module handles the generation of Dockerfiles which can be used for the
  deploy process.

  This can either directly be called, or called through a mix task,
  `mix akd.gen.dockerfile`.

  This class uses EEx and Mix.Generator to fetch file contents from an eex
  template and populate the interpolated fields, writing it to the speficied
  file.

  ## Usage:

  The following call creates a file `Dockerfile` at location `path/to/file/Dockerfile`

  ```
  Akd.Generator.Dockerfile.gen(["Dockerfile"], path: "path/to/file")
  ```

  """

  require EEx
  require Mix.Generator

  @path "./"
  @name "Dockerfile"

  @doc """
  This is the callback implementation for `gen/2`.

  This function takes in a list of inputs and a list of options and generates
  a Dockerfile at the specified path with the specified name.

  The first element of the input is expected to be the name of the file.
  If no name is given, it defaults to #{@name}

  The path can be sent to the `opts`.

  If no path is sent, it defaults to #{@path}

  ## Examples:

    Akd.Generator.Dockerfile.gen(["Dockerfile"], [path: "some/path"])

  """
  @spec gen(list, Keyword.t) :: :ok | {:error, String.t}
  def gen([], opts), do: gen([@name], opts)
  def gen([name | _], opts) do
    name
    |> validate_and_format_opts(opts)
    |> text_from_template()
    |> write_to_file(name)
  end

  # This function validates the name and options sent to the generator
  # and formats the options making it ready for the template to read from.
  defp validate_and_format_opts(name, opts) do
    opts = Keyword.put_new(opts, :path, @path)

    opts = opts
      |> Keyword.get_values(:envs)
      |> Enum.map(&String.split(&1, "="))
      |> Enum.map(&List.to_tuple/1)
      |> (&Keyword.put(opts, :envs, &1)).()

    opts = opts
      |> Keyword.get_values(:phxapps)
      |> (&Keyword.put(opts, :phxapps, &1)).()

    [{:name, name} | opts]
  end

  # This function gives the location for the template which will be used
  # by the generator
  defp template(type, os) do
    "#{__DIR__}/templates/docker/#{type}/#{os}/Dockerfile.eex"
  end

  # This function takes formatted options and returns a tuple.
  # First element of the tuple is the path to file and second element is
  # the evaluated file string.
  defp text_from_template(opts) do
    {Keyword.get(opts, :path), EEx.eval_file(template(opts[:type], opts[:os]), assigns: opts)}
  end

  # This function writes contents to a file at a specific path
  defp write_to_file({path, code}, name) do
    path = path <> name

    case File.exists?(path) do
      true -> {:error, "File #{path} already exists."}
      _ -> Mix.Generator.create_file(path, code)
    end
  end
end

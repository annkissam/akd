defmodule Akd.Generator.Hook do
  @moduledoc false

  require EEx
  require Mix.Generator

  @path "lib/"

  def gen([name | _], opts) do
    name
    |> validate_and_format_opts(opts)
    |> text_from_template()
    |> write_to_file(name)
  end

  defp validate_and_format_opts(name, opts) do
    opts = Keyword.put_new(opts, :path, @path)
    [{:name, resolve_name(name)} | opts]
  end

  defp resolve_name(name) do
    Macro.camelize(name)
  end

  defp template(), do:  "#{__DIR__}/templates/hook.ex.eex"

  defp text_from_template(opts) do
    {Keyword.get(opts, :path), EEx.eval_file(template(), assigns: opts)}
  end

  defp write_to_file({path, code}, name) do
    path = path <> Macro.underscore(name) <> ".ex"

    case File.exists?(path) do
      true -> {:error, "File #{path} already exists."}
      _ -> Mix.Generator.create_file(path, code)
    end
  end
end

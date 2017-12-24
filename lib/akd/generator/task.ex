defmodule Akd.Generator.Task do
  @moduledoc false

  require EEx
  require Mix.Generator

  @path "lib/"

  @hooks ~w(fetch init build publish)a

  @spec gen(list, Keyword.t) :: :ok | {:error, String.t}
  def gen([name | _], opts) do
    name
    |> validate_and_format_opts(opts)
    |> text_from_template()
    |> write_to_file(name)
  end

  defp validate_and_format_opts(name, opts) do
    # TODO Do something with opts[:phx]
    opts = Enum.reduce(@hooks, opts, &resolve_hook_opts/2)
    [{:name, resolve_name(name)} | opts]
  end

  defp resolve_hook_opts(hook, opts) do
    Keyword.put_new(opts, hook, default_string(hook))
  end

  defp default_string(hook) do
    Akd
    |> apply(hook, [])
    |> Macro.to_string()
  end

  defp resolve_name(name) do
    Macro.camelize(name)
  end

  defp template(), do:  "#{__DIR__}/templates/task.ex.eex"

  defp text_from_template(opts) do
    EEx.eval_file(template(), assigns: opts)
  end

  defp write_to_file(code, name) do
    path = @path <> Macro.underscore(name) <> ".ex"

    case File.exists?(path) do
      true -> {:error, "File #{path} already exists."}
      _ -> Mix.Generator.create_file(path, code)
    end
  end
end

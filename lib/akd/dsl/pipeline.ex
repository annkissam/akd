defmodule Akd.Pipeline do
  @moduledoc """
  This modules provides a DSL to interact with Akd.DeployHelper module.
  """

  alias Akd.{Pipeline}

  defmacro pipeline(name, do: block) do
    quote do
      def unquote(name)() do
        {:ok, var!(buff, Pipeline)} = start_buffer([])

        unquote(block)
        get_buffer(var!(buff, Pipeline))
      end
    end
  end

  defmacro hook(hook) do
    quote do: put_buffer(var!(buff, Pipeline), unquote(hook))
  end

  defmacro pipe_through(pipeline) do
    quote do
      __MODULE__
      |> apply(unquote(pipeline), [])
      |> Enum.each(&put_buffer(var!(buff, Pipeline), &1))
    end
  end

  def start_buffer(state), do: Agent.start_link(fn -> state end)
  def stop_buffer(buff), do: Agent.stop(buff)
  def put_buffer(buff, hook), do: Agent.update(buff, &[hook | &1])
  def get_buffer(buff), do: Agent.get(buff, & &1) |> Enum.reverse()
end

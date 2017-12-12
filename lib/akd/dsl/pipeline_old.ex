# defmodule Akd.Pipeline do
#   alias Akd.{Hook, Pipeline}
#
#   defmacro __using__(_) do
#     quote do
#       import Pipeline
#     end
#   end
#
#   defmacro pipeline(hook, do: block) do
#     block = quote do: unquote(block)
#
#     quote do
#       unquote(@hooks [])
#       unquote(block)
#
#       def unquote(hook)() do
#         unquote(@hooks)
#       end
#     end
#   end
#
#   defmacro hook(exec_env, fun) do
#     quote do
#       unquote(@hooks @hooks ++ [%Hook{exec_env: unquote(exec_env)}])
#     end
#   end
#
#   defmacro pipe_through(name) do
#     quote do
#       @hooks @hooks ++ [%Hook{exec_env: unquote(exec_env)}]
#       update_hooks(__MODULE__, fn(hooks) ->
#         [hooks] ++ unquote(name)
#       end)
#     end
#   end
#
#   defmacro cleanup(name, exec_env, opts \\ []) do
#     quote do
#       @pipe_through [p | %{name: unquote(name), exec_env: unquote(exec_env), opts: unquote(opts)}]
#     end
#   end
#
#   def add_hook(module, %Hook{} = hook) do
#     update_hooks(module, &MapSet.put(&1, hook))
#   end
#
#   def get_hooks(module) do
#     Module.get_attribute(module, @hooks)
#   end
#
#   def update_hooks(module, fun) do
#     hooks = Module.get_attribute(module, @hooks)
#     Module.put_attribute(module, @hooks, fun.(hooks))
#   end
# end

# defmodule X do
#   use Pipeline
#
#   pipeline :fetch do
#     hook :build_env, fn(_) -> "" end
#   end
#
#   pipeline :build do
#     hook :build_env, fn(_) -> "" end
#   end
#
#   pipeline :publish do
#     hook :local, fn(_) -> "" end
#   end
#
#   pipeline :deploy do
#     pipe_through :fetch
#     hook :build_env, fn(_) -> "pre-build commands" end
#     pipe_through :build
#     pipe_through :publish
#     hook :publish_env, fn(_) -> "run migration" end
#   end
#
#   def run() do
#     IO.inspect publish()
#   end
# end
#
# X.run()

defmodule Akd.Fetcher.Scp do
  @moduledoc """
  Fetches source code using scp. This is a basic fetcher that just copies
  the code that the task is ran from to the build env
  """

  @behaviour Akd.Hook

  alias Akd.{Deployment, Destination, DestinationResolver, Hook}

  def get_hook(%Deployment{buildat: buildat} = deployment, opts) do
    {commands, cleanup} = commands(opts[:src] || ".", buildat)
    runat = opts[:runat] || DestinationResolver.resolve(:local, deployment)

    %Hook{commands: commands, runat: runat, cleanup: cleanup, env: opts[:env]}
  end

  # This assumes that you're running this command from the same server
  defp commands(%Destination{server: s} = src, %Destination{server: s} = dest) do
    {"cp -r #{src.path} #{dest.path}", "rm -rf #{dest.path}"}
  end
  defp commands(%Destination{} = src, %Destination{} = dest) do
    {"scp -r #{Destination.to_s(src)} #{Destination.to_s(dest)}",
      """
      ssh #{dest.user}@#{dest.server}
      rm -rf #{dest.path}
      """}
  end
  defp commands(src, %Destination{} = dest) when is_binary(src) do
    {
    """
    rsync -krav -e ssh --exclude="_build" --exclude=".git" --exclude="deps" #{src} #{Destination.to_s(dest)}
    """,
      """
      ssh #{dest.user}@#{dest.server}
      rm -rf #{dest.path}
      """}
  end
end

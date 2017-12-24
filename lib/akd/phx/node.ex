defmodule Akd.Builder.Phoenix.Npm do
  @moduledoc """
  TODO: Improve Docs
  """

  use Akd.Hook

  def get_hooks(deployment, opts \\ []) do
    package_path = Keyword.get(opts, :package, ".")

    [build_hook(deployment, opts, package_path)]
  end

  defp build_hook(deployment, opts, package_path) do
    destination = Akd.DestinationResolver.resolve(:build, deployment)

    form_hook opts do
      main "cd #{package_path} \n npm install", destination

      ensure "cd #{package_path} \n rm -rf node_modules", destination
    end
  end
end

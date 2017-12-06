defmodule Akd.Deployment do
  @moduledoc """
  This module encapsulates a `Deployment` struct which contains information
  such as environment, build environment, publish environment, name of the app,
  app's version and release path.
  """

  alias Akd.{Destination, Hook}

  @enforce_keys ~w(app_env build_env publish_env appname version)a
  @optional_keys ~w(release hooks cleanup)a

  defstruct @enforce_keys ++ @optional_keys

  @typedoc ~s(Generic type for a Deployment struct)
  @type t :: %__MODULE__{
    app_env: String.t,
    build_env: Destination.t,
    publish_env: Destination.t,
    appname: Atom.t,
    version: String.t,
    release: Destination.t | nil,
    hooks: [Akd.Hook.t],
    cleanup: [Akd.Hook.t]
  }
end

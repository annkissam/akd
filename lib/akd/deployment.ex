defmodule Akd.Deployment do
  @moduledoc """
  This module encapsulates a `Deployment` struct which contains information
  such as environment, build environment, publish environment, name of the app,
  app's version and deployable path.
  """

  alias Akd.{Destination, Hook}

  @enforce_keys ~w(env buildat publishto appname version)a
  @optional_keys ~w(deployable hooks)a

  defstruct @enforce_keys ++ @optional_keys

  @typedoc ~s(Generic type for a Deployment struct)
  @type t :: %__MODULE__{
    env: String.t,
    buildat: Destination.t,
    publishto: Destination.t,
    appname: Atom.t,
    version: String.t | nil,
    deployable: Destination.t | nil,
    hooks: [Akd.Hook.t] | nil,
  }
end

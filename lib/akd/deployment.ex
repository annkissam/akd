defmodule Akd.Deployment do
  @moduledoc """
  This module represents a `Deployment` struct which contains metadata about
  a deployment.

  The meta data involves:

  * `build_at` - `Akd.Destination.t` where the app/node will be built/released.
  * `mix_env` - Mix environment to build the app, represented by a `String.t`.
  * `name` - Name with which the app/node will be published.
  * `publish_to` - `Akd.Destination.t` where the app/node will be published.
  * `vsn` - Version of app that is being released, represented by a `String.t`.
  * `hooks` - A list of `Akd.Hook.t` that will be run in order when a deployment
            is executed.

  This struct is mainly used by native hooks in `Akd`, but it can be leveraged
  to produce custom hooks.
  """

  alias Akd.{Destination, Hook}

  @enforce_keys ~w(mix_env build_at publish_to name vsn)a
  @optional_keys [hooks: [], data: %{}]

  defstruct @enforce_keys ++ @optional_keys

  @typedoc ~s(Generic type for a Deployment struct)
  @type t :: %__MODULE__{
          mix_env: String.t(),
          build_at: Destination.t(),
          publish_to: Destination.t(),
          name: String.t(),
          vsn: String.t(),
          hooks: [Hook.t()],
          data: Map.t()
        }
end

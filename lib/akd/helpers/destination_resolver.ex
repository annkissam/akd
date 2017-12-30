defmodule Akd.DestinationResolver do
  @moduledoc """
  This module defines helper functions which can be used to resolve
  a destination for based on deployment and the destination type
  """

  alias Akd.{Destination, Deployment}

  @doc """
  This function takes a `destination` variable and a `Deployment.t` struct.

  `destination` variable could be either a `Destination.t` struct or one of the
  atoms: `:build, :publish, :local`

  This function returns a resolved `Destination.t` struct.

  ## Examples
  When a `Destination.t` struct is passed:

      iex> destination = Akd.Destination.local()
      iex> deployment = %Akd.Deployment{mix_env: "prod",
      ...> build_at: Akd.Destination.local("."),
      ...> publish_to: Akd.Destination.local("."),
      ...> name: "name",
      ...> vsn: "0.1.1"}
      iex> Akd.DestinationResolver.resolve(destination, deployment)
      %Akd.Destination{user: :current, host: :local, path: "."}

  When `:build` is passed:

      iex> deployment = %Akd.Deployment{mix_env: "prod",
      ...> build_at: Akd.Destination.local("build"),
      ...> publish_to: Akd.Destination.local("publish"),
      ...> name: "name",
      ...> vsn: "0.1.1"}
      iex> Akd.DestinationResolver.resolve(:build, deployment)
      %Akd.Destination{user: :current, host: :local, path: "build"}

  When `:publish` is passed:

      iex> deployment = %Akd.Deployment{mix_env: "prod",
      ...> build_at: Akd.Destination.local("build"),
      ...> publish_to: Akd.Destination.local("publish"),
      ...> name: "name",
      ...> vsn: "0.1.1"}
      iex> Akd.DestinationResolver.resolve(:publish, deployment)
      %Akd.Destination{user: :current, host: :local, path: "publish"}

  When `:local` is passed:

      iex> deployment = %Akd.Deployment{mix_env: "prod",
      ...> build_at: Akd.Destination.local("build"),
      ...> publish_to: Akd.Destination.local("publish"),
      ...> name: "name",
      ...> vsn: "0.1.1"}
      iex> Akd.DestinationResolver.resolve(:local, deployment)
      %Akd.Destination{user: :current, host: :local, path: "."}
  """
  @spec resolve(Destination.t | :build | :publish | :local, Deployment.t) :: Destination.t
  def resolve(dest, deployment)

  def resolve(%Destination{} = dest, _deployment), do: dest

  def resolve(:build, deployment), do: deployment.build_at

  def resolve(:publish, deployment), do: deployment.publish_to

  def resolve(:local, _deployment), do: Destination.local()
end

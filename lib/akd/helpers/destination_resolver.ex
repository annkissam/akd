defmodule Akd.DestinationResolver do
  @moduledoc """
  This module defines helper functions which can be used to resolve
  a destination for based on deployment and the destination type
  """

  alias Akd.{Destination, Deployment}

  @spec resolve(Destination.t | :build | :publish | :local, Deployment.t) :: Destination.t
  def resolve(dest, deployment)

  def resolve(%Destination{} = dest, _deployment), do: dest

  def resolve(:build, deployment), do: deployment.build_at

  def resolve(:publish, deployment), do: deployment.publish_to

  def resolve(:local, _deployment), do: Destination.local()
end

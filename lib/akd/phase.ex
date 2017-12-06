defmodule Akd.Phase do
  @moduledoc """
  This module defines a behavior that all `Phases` have to follow to be
  able to successfully work with this package
  """

  @callback run(deployment :: Akd.Deployment.t) :: {:ok, String.t} | {:error, String.t}
  @callback cleanup(deployment :: Akd.Deployment.t) :: :ok | {:error, String.t}
end

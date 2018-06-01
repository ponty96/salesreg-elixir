defmodule SalesReg.Store do
  @moduledoc """
  The Store context.
  """

  import Ecto.Query, warn: false
  alias SalesReg.Repo
  use SalesRegWeb, :context

  use SalesReg.Context, [
    Product,
    Service
  ]
end

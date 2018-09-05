defmodule SalesReg.Store do
  @moduledoc """
  The Store context.
  """

  import Ecto.Query, warn: false
  use SalesRegWeb, :context

  use SalesReg.Context, [
    Product,
    Service
  ]
end

defmodule SalesReg.Order do
  @moduledoc """
  The Order context.
  """

  import Ecto.Query, warn: false
  alias SalesReg.Repo
  use SalesRegWeb, :context

  use SalesReg.Context, [
    Purchase,
    Sale
  ]

  def list_purchases do
    Repo.all(Purchase)
  end

  def create_purchase(attrs \\ %{}) do
    %Purchase{}
    |> Purchase.changeset(attrs)
    |> Repo.insert()
  end
end

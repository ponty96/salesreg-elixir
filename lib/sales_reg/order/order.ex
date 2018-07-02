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

  def list_vendor_purchases(vendor_id) do
    Repo.all(from(p in Purchase, where: p.vendor_id == ^vendor_id))
  end

  def list_customer_sales(customer_id) do
    Repo.all(from(s in Sale, where: s.customer_id == ^customer_id))
  end

  def create_purchase(attrs \\ %{}) do
    %Purchase{}
    |> Purchase.changeset(attrs)
    |> Repo.insert()
  end
end

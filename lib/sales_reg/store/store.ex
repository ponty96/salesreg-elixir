defmodule SalesReg.Store do
  @moduledoc """
  The Store context.
  """

  import Ecto.Query, warn: false
  alias SalesReg.Repo

  alias SalesReg.Store.Product

  def get_product!(id), do: Repo.get!(Product, id)

  def create_product(attrs \\ %{}) do
    %Product{}
    |> Product.changeset(attrs)
    |> Repo.insert()
  end

  def update_product(id, attrs) do
    get_product!(id)
    |> Product.changeset(attrs)
    |> Repo.update()
  end

  def list_company_products(company_id) do
    products =
      from(prod in Product, where: prod.company_id == ^company_id)
      |> Repo.all()

    {:ok, products}
  end
end

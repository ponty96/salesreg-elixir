defmodule SalesReg.Store.ProductGroup do
  @moduledoc """
  Product Group Schema Module
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias SalesReg.Repo
  alias SalesReg.Store

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "product_groups" do
    field(:title, :string)
    field(:company_id, :binary_id)

    many_to_many(:options, Store.Option,
      join_through: "product_groups_options",
      on_replace: :delete
    )

    has_many(:products, Store.Product)
    timestamps()
  end

  @doc false
  def changeset(product_group, attrs) do
    product_group
    |> Repo.preload(:options)
    |> cast(attrs, [:title, :company_id])
    |> validate_required([:title, :company_id])
    |> put_assoc(:options, Store.load_product_grp_options(attrs))
  end
end

defmodule SalesReg.Store.ProductGroup do
  use Ecto.Schema
  import Ecto.Changeset

  alias SalesReg.Store
  alias SalesReg.Repo

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "product_groups" do
    field(:title, :string)
    field(:company_id, :binary_id)

    many_to_many(:options, Store.ProductGroup,
      join_through: "product_groups_options",
      on_replace: :delete,
      on_delete: :delete_all
    )
    has_many(:products, Store.Product)
    timestamps()
  end

  @doc false
  def changeset(product_group, attrs) do
    product_group
    |> Repo.preload(:options)
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end

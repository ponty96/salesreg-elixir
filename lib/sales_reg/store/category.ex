defmodule SalesReg.Store.Category do
  use Ecto.Schema
  import Ecto.Changeset

  alias SalesReg.Store.Product
  alias SalesReg.Repo

  @placeholder_image 'http://app.yipcart.com/images/yipcart-item-category.png'

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "categories" do
    field(:description, :string)
    field(:title, :string)

    belongs_to(:company, SalesReg.Business.Company)
    belongs_to(:user, SalesReg.Accounts.User)

    many_to_many(:products, Product, join_through: "products_categories")
    timestamps()
  end

  @fields [
    :description
  ]

  @required_fields [
    :company_id,
    :user_id,
    :title
  ]
  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, @fields ++ @required_fields)
    |> validate_required(@required_fields)
    |> assoc_constraint(:company)
    |> assoc_constraint(:user)
  end

  def delete_changeset(category) do
    category
    |> cast(%{}, [])
  end

  def category_image(category),
    do: get_category_image(Repo.preload(category, [:products]))

  defp get_category_image(%{products: []}), do: @placeholder_image

  defp get_category_image(%{products: products}) do
    Enum.random(products).featured_image
  end
end

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

    field(:slug, :string)

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
    |> assoc_constraint(:company)
    |> assoc_constraint(:user)
    |> unique_constraint(:title,
      name: "categories_title_company_id_index",
      message: "category already exist"
    )
    |> add_slug(attrs)
    |> unique_constraint(:slug)
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

  defp add_slug(changeset, attrs) do
    title = Map.get(attrs, :title) |> String.split(" ") |> Enum.join("-")

    hash =
      Map.get(attrs, :company_id)
      |> String.split("-")
      |> List.last()

    slug = "#{title}-#{hash}"

    slug =
      slug
      |> String.downcase()
      |> URI.encode()

    put_change(changeset, :slug, slug)
  end
end

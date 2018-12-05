defmodule SalesReg.Store.Service do
  use Ecto.Schema
  import Ecto.Changeset
  alias SalesReg.Store.Category
  alias SalesReg.Repo
  alias SalesReg.Store

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "services" do
    field(:description, :string)
    field(:name, :string)
    field(:price, :string)
    field(:featured_image, :string)
    field(:images, {:array, :string})
    field(:is_featured, :boolean)
    field(:is_top_rated_by_merchant, :boolean)

    belongs_to(:company, SalesReg.Business.Company)
    belongs_to(:user, SalesReg.Accounts.User)

    has_many(:items, SalesReg.Order.Item)
    has_many(:review, SalesReg.Order.Review)
    has_many(:star, SalesReg.Order.Star)

    many_to_many(
      :categories,
      Category,
      join_through: "services_categories",
      on_replace: :delete,
      on_delete: :delete_all
    )

    many_to_many(:tags, SalesReg.Store.Tag, join_through: "services_tags", on_delete: :delete_all)

    timestamps()
  end

  @required_fields [:name, :price, :company_id, :user_id, :featured_image]
  @optional_fields [:description, :images, :is_featured, :is_top_rated_by_merchant]

  @doc false
  def changeset(service, attrs) do
    service
    |> Repo.preload(:categories)
    |> Repo.preload(:tags)
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> assoc_constraint(:company)
    |> assoc_constraint(:user)
    |> put_assoc(:categories, Store.load_categories(attrs))
    |> put_assoc(:tags, Store.load_tags(attrs))
    |> no_assoc_constraint(:items, message: "This service is still associated with sales")
  end

  def delete_changeset(service) do
    service
    |> Repo.preload(:categories)
    |> Repo.preload(:tags)
    |> Repo.preload(:items)
    |> cast(%{}, [])
    |> no_assoc_constraint(:items, message: "This service is still associated with sales")
  end
end

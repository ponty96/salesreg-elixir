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

    belongs_to(:company, SalesReg.Business.Company)
    belongs_to(:user, SalesReg.Accounts.User)

    has_many(:items, SalesReg.Order.Item)

    many_to_many(
      :categories,
      Category,
      join_through: "services_categories",
      on_replace: :delete
    )

    many_to_many(:tags, SalesReg.Store.Tag, join_through: "services_tags")

    timestamps()
  end

  @required_fields [:name, :price, :company_id, :user_id, :featured_image]
  @optional_fields [:description, :images]

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
    |> cast(%{}, @required_fields ++ @optional_fields)
    |> no_assoc_constraint(:items, message: "This service is still associated with sales")
  end
end

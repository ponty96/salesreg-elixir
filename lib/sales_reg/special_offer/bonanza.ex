defmodule SalesReg.SpecialOffer.Bonanza do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "bonanzas" do
    field(:title, :string)
    field(:cover_photo, :string)
    field(:start_date, :string)
    field(:end_date, :string)
    field(:slug, :string)
    field(:description, :string)

    has_many(:sales, SalesReg.Order.Sale)
    has_many(:bonanza_items, SalesReg.SpecialOffer.BonanzaItem)

    belongs_to(:company, SalesReg.Business.Company)
    belongs_to(:user, SalesReg.Accounts.User)

    timestamps()
  end

  @required_fields [
    :title,
    :start_date,
    :end_date,
    :company_id,
    :user_id
  ]

  @optional_fields [:cover_photo, :slug, :description]

  @doc false
  def changeset(bonanza, attrs) do
    bonanza
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> assoc_constraint(:company)
    |> unique_constraint(:slug)
    |> cast_assoc(:bonanza_items)
  end

  def delete_changeset(category) do
    category
    |> cast(%{}, [])
  end
end

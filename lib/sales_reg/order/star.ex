defmodule SalesReg.Order.Star do
  @moduledoc """
  Star Schema Module
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias SalesReg.Repo

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "star" do
    field(:value, :integer, default: 0)

    belongs_to(:sale, SalesReg.Order.Sale)
    belongs_to(:product, SalesReg.Store.Product)
    belongs_to(:contact, SalesReg.Business.Contact)
    belongs_to(:company, SalesReg.Business.Company)

    timestamps()
  end

  @required_fields [:value, :sale_id, :contact_id, :product_id, :company_id]

  def changeset(star, attrs) do
    star
    |> Repo.preload([:sale, :contact])
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:value, 0..5)
  end
end

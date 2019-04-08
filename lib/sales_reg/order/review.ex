defmodule SalesReg.Order.Review do
  @moduledoc """
  Review Schema Module
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias SalesReg.Repo

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "review" do
    field(:text, :string)

    belongs_to(:sale, SalesReg.Order.Sale)
    belongs_to(:product, SalesReg.Store.Product)
    belongs_to(:contact, SalesReg.Business.Contact)
    belongs_to(:company, SalesReg.Business.Company)

    timestamps()
  end

  @required_fields [:text, :sale_id, :contact_id, :product_id, :company_id]

  def changeset(review, attrs) do
    review
    |> Repo.preload([:sale, :contact])
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end

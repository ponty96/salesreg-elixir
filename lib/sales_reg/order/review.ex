defmodule SalesReg.Order.Review do
  use Ecto.Schema
  import Ecto.Changeset
  alias SalesReg.Repo

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "review" do
    field(:text, :string)

    belongs_to(:sale, SalesReg.Order.Sale)
    belongs_to(:product, SalesReg.Store.Product)
    belongs_to(:service, SalesReg.Store.Service)
    belongs_to(:contact, SalesReg.Business.Contact)

    timestamps()
  end

  @required_fields [
    :text,
    :sale_id,
    :contact_id
  ]

  @optional_fields [:service_id, :product_id]

  def changeset(review, attrs) do
    IO.inspect review, label: "review"
    IO.inspect attrs, label: "attrs"
    review
    |> Repo.preload([:sale, :contact])
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    # |> validate_product_or_service()
    |> unique_constraint(:product, name: :review_index_on_product)
    |> unique_constraint(:service, name: :review_index_on_service)
  end

  defp validate_product_or_service(changeset) do
    validate_change(changeset, :product_id, fn _, :service_id ->
      if :product_id == nil do 
        [:service_id]
      else 
        []
      end
    end)
  end
end
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
  @required_fields [:text, :sale_id, :contact_id]
  @optional_fields [:service_id, :product_id]

  def changeset(review, attrs) do
    review
    |> Repo.preload([:sale, :contact])
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_product_or_service(attrs)
  end

  defp validate_product_or_service(changeset, %{"product_id" => _}) do
    changeset
    |> validate_required(:product_id)
  end

  defp validate_product_or_service(changeset, %{"service_id" => _}) do
    changeset
    |> validate_required(:service_id)
  end

  defp validate_product_or_service(changeset, _attrs) do
    changeset
    |> add_error(:product_id, "either product or service is required")
    |> add_error(:service_id, "either product or service is required")
  end
end
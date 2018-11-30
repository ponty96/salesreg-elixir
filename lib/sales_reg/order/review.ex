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

  def changeset(review, attrs) do
    IO.inspect review, label: "review"
    IO.inspect attrs, label: "attrs"
    review
    |> Repo.preload([:sale, :contact])
    |> cast(attrs, ~w(text sale_id contact_id service_id product_id)a)
    |> validate_required([:text, :sale_id, :contact_id])
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
    |> add_error(:attrs, "either :product_id or :service_id is required")
  end
end
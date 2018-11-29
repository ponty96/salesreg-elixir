defmodule SalesReg.Order.Sale do
  use Ecto.Schema
  import Ecto.Changeset
  alias SalesReg.Repo

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @order_status ["pending", "processed", "delivering", "recalled", "delivered"]
  schema "sales" do
    field(:date, :string)
    field(:status, :string, default: "pending")
    field(:amount, :string)
    field(:payment_method, :string)
    field(:tax, :string)

    field(:state, :string, virtual: true)

    has_one(:invoice, SalesReg.Order.Invoice)
    has_many(:items, SalesReg.Order.Item, on_replace: :delete)
    has_many(:review, SalesReg.Order.Review)
    has_many(:star, SalesReg.Order.Star)

    belongs_to(:user, SalesReg.Accounts.User)
    belongs_to(:contact, SalesReg.Business.Contact)
    belongs_to(:company, SalesReg.Business.Company)

    timestamps()
  end

  @required_fields [
    :amount,
    :payment_method,
    :user_id,
    :contact_id,
    :company_id,
    :date
  ]

  @optional_fields [:status, :tax]

  @doc false
  def changeset(sale, attrs) do
    sale
    |> Repo.preload([:items])
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> cast_assoc(:items)
    |> assoc_constraint(:company)
    |> assoc_constraint(:user)
    |> assoc_constraint(:contact)
    |> validate_payment_method()
    |> validate_inclusion(:status, @order_status)
  end

  defp validate_payment_method(changeset) do
    case get_field(changeset, :payment_method) do
      "POS" -> changeset
      "cheque" -> changeset
      "direct transfer" -> changeset
      "cash" -> changeset
      _ -> add_error(changeset, :payment_method, "Invalid payment method")
    end
  end

  def delete_changeset(sale) do
    sale
    |> Repo.preload(:items)
    |> cast(%{}, @required_fields ++ @optional_fields)
    |> no_assoc_constraint(:items,
      message: "This sale is still associated with a product or service "
    )
  end
end

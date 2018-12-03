defmodule SalesReg.Order.Receipt do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "receipts" do
    field(:amount_paid, :string)
    field(:time_paid, :string)
    field(:payment_method, :string)
    field(:pdf_url, :string)
    field(:reference_id, :string)

    belongs_to(:invoice, SalesReg.Order.Invoice)
    belongs_to(:user, SalesReg.Accounts.User)
    belongs_to(:company, SalesReg.Business.Company)
    belongs_to(:sale, SalesReg.Order.Sale)

    timestamps()
  end

  @required_fields [
    :amount_paid,
    :time_paid,
    :payment_method,
    :invoice_id,
    :user_id,
    :company_id,
    :sale_id
  ]

  @optional_fields [:pdf_url, :reference_id]

  def changeset(receipts, attrs) do
    receipts
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_payment_method()
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
end

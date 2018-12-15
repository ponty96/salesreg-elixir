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
    field(:transaction_id, :integer)
    field(:ref_id, :string)

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
    :sale_id,
    :ref_id
  ]
  @optional_fields [:pdf_url, :transaction_id]

  def changeset(receipt, attrs) do
    new_attrs = SalesReg.Order.put_ref_id(SalesReg.Order.Receipt, attrs)
    
    receipt
    |> cast(new_attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end

  def via_cash_changeset(receipt, attrs) do
    new_attrs = SalesReg.Order.put_ref_id(SalesReg.Order.Invoice, attrs)
    
    receipt
    |> cast(new_attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:payment_method, ["cash"], message: "The payment method must be cash")
  end
end

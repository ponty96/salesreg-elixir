defmodule SalesReg.Order.Receipt do
  @moduledoc """
  Receipt Schema Module
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias SalesReg.Base
  alias SalesReg.Business
  alias SalesReg.Repo

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "receipts" do
    field(:amount_paid, :decimal)
    field(:time_paid, :date)
    field(:payment_method, :string, default: "card")
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
  @number_fields [:amount_paid]

  def changeset(receipt, attrs) do
    new_attrs =
      SalesReg.Order.Receipt
      |> SalesReg.Order.put_ref_id(attrs)
      |> Base.transform_string_keys_to_numbers([:amount_paid])

    receipt
    |> cast(new_attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> Base.validate_changeset_number_values(@number_fields)
  end

  def via_cash_changeset(receipt, attrs) do
    new_attrs =
      SalesReg.Order.Invoice
      |> SalesReg.Order.put_ref_id(attrs)
      |> Base.transform_string_keys_to_numbers([:amount_paid])

    receipt
    |> cast(new_attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:payment_method, ["cash"], message: "The payment method must be cash")
    |> Base.validate_changeset_number_values(@number_fields)
  end

  def get_receipt_share_link(receipt) do
    receipt = Repo.preload(receipt, [:company])
    "#{Business.get_company_share_domain()}/#{receipt.company.slug}/r/#{receipt.id}"
  end
end

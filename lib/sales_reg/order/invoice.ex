defmodule SalesReg.Order.Invoice do
  @moduledoc """
  Invoice Schema Module
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias SalesReg.Business
  alias SalesReg.Order
  alias SalesReg.Repo

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "invoices" do
    field(:due_date, :date)
    field(:pdf_url, :string)
    field(:ref_id, :string)

    has_many(:receipts, SalesReg.Order.Receipt)
    belongs_to(:sale, SalesReg.Order.Sale)
    belongs_to(:user, SalesReg.Accounts.User)
    belongs_to(:company, SalesReg.Business.Company)

    timestamps()
  end

  @required_fields [
    :due_date,
    :sale_id,
    :user_id,
    :company_id,
    :ref_id
  ]
  @optional_fields [:pdf_url]

  def changeset(invoice, attrs) do
    invoice
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> before_update_callback(attrs)
    |> validate_required(@required_fields)
    |> assoc_constraint(:sale)
    |> assoc_constraint(:user)
    |> assoc_constraint(:company)
  end

  def get_invoice_share_link(invoice) do
    invoice = Repo.preload(invoice, [:company])
    "#{Business.get_company_share_url(invoice.company.slug)}/invoices/#{invoice.id}"
  end

  defp before_update_callback(changeset, attrs) do
    if Enum.count(changeset.changes) > 1 do
      ref_id =
        SalesReg.Order.Sale
        |> SalesReg.Order.put_ref_id(attrs)
        |> Map.get(:ref_id)

      changeset
      |> put_change(:ref_id, ref_id)
      |> put_change(:charge, Order.sale_charge() |> Decimal.new())
    else
      changeset
    end
  end
end

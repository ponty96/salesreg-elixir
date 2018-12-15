defmodule SalesReg.Order.Invoice do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "invoices" do
    field(:due_date, :string)
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
    new_attrs = SalesReg.Order.put_ref_id(SalesReg.Order.Invoice, attrs)

    invoice
    |> cast(new_attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> assoc_constraint(:sale)
    |> assoc_constraint(:user)
    |> assoc_constraint(:company)
  end
end

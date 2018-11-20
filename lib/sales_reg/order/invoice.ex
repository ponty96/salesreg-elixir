defmodule SalesReg.Order.Invoice do
  use Ecto.Schema
  import Ecto.Changeset

  schema "invoices" do
    field(:due_date, :string)

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
    :company_id
  ]

  def changeset(invoice, attrs) do
    invoice
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> assoc_constraint(:sale)
  end
end

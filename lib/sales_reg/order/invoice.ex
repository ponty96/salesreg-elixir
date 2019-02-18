defmodule SalesReg.Order.Invoice do
  use Ecto.Schema
  import Ecto.Changeset
  alias SalesReg.Business
  alias SalesReg.Repo

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "invoices" do
    field(:due_date, :string)
    field(:pdf_url, :string)
    field(:ref_id, :string)
    field(:allows_split_payment, :boolean, default: false)

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
  @optional_fields [:pdf_url, :allows_split_payment]

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
    "#{Business.get_company_share_domain()}/#{invoice.company.slug}/in/#{invoice.id}"
  end

  defp before_update_callback(changeset, attrs) do
    if Enum.count(changeset.changes) > 1 do
      ref_id =
        SalesReg.Order.put_ref_id(SalesReg.Order.Sale, attrs)
        |> Map.get(:ref_id)

      changeset
      |> put_change(:ref_id, ref_id)
      |> put_change(:charge, "#{System.get_env("CHARGE")}")
    else
      changeset
    end
  end
end

defmodule SalesReg.Order.Sale do
  use Ecto.Schema
  import Ecto.Changeset
  alias SalesReg.Repo

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "sales" do
    field(:date, :string)
    field(:status, :string, default: "pending")
    field(:amount, :string)
    field(:payment_method, :string)
    field(:tax, :string)

    has_many(:items, SalesReg.Order.Item, on_replace: :delete)
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

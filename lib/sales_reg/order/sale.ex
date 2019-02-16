defmodule SalesReg.Order.Sale do
  use Ecto.Schema
  import Ecto.Changeset
  alias SalesReg.Business
  alias SalesReg.Repo

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @order_status ["pending", "processed", "delivering", "recalled", "delivered"]
  schema "sales" do
    field(:date, :string)
    field(:status, :string, default: "pending")
    field(:payment_method, :string)
    field(:tax, :string)
    field(:discount, :string)
    field(:ref_id, :string)
    field(:charge, :string)

    field(:state, :string, virtual: true)

    has_one(:invoice, SalesReg.Order.Invoice)
    has_one(:location, SalesReg.Business.Location)
    has_many(:items, SalesReg.Order.Item, on_replace: :delete)
    has_many(:reviews, SalesReg.Order.Review)
    has_many(:stars, SalesReg.Order.Star)

    belongs_to(:user, SalesReg.Accounts.User)
    belongs_to(:contact, SalesReg.Business.Contact)
    belongs_to(:company, SalesReg.Business.Company)

    timestamps()
  end

  @required_fields [
    :payment_method,
    :user_id,
    :contact_id,
    :company_id,
    :date,
    :ref_id,
    :charge
  ]
  @optional_fields [:status, :tax, :discount]

  @doc false
  def changeset(sale, attrs) do
    sale
    |> Repo.preload([:items, :location])
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> before_update_callback(attrs)
    |> validate_required(@required_fields)
    |> cast_assoc(:items)
    |> cast_assoc(:location)
    |> assoc_constraint(:company)
    |> assoc_constraint(:user)
    |> assoc_constraint(:contact)
    |> validate_payment_method()
    |> validate_inclusion(:status, @order_status)
  end

  defp validate_payment_method(changeset) do
    case get_field(changeset, :payment_method) do
      "card" -> changeset
      "cash" -> changeset
      _ -> add_error(changeset, :payment_method, "Invalid payment method")
    end
  end

  def delete_changeset(sale) do
    sale
    |> Repo.preload(:items)
    |> cast(%{}, [])
    |> no_assoc_constraint(:items,
      message: "This sale is still associated with a product"
    )
  end

  def get_sale_share_link(sale) do
    sale = Repo.preload(sale, [:company])
    "#{Business.get_company_share_domain()}/#{sale.company.slug}/s/#{sale.id}"
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

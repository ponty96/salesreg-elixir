defmodule SalesReg.Order.Sale do
  @moduledoc """
  Sale Schema Module
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias SalesReg.Base
  alias SalesReg.Business
  alias SalesReg.Order
  alias SalesReg.Repo

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @order_status ["pending", "processed", "delivering", "recalled", "delivered"]
  schema "sales" do
    field(:date, :date)
    field(:status, :string, default: "pending")
    field(:payment_method, :string)
    field(:tax, :decimal)
    field(:discount, :decimal)
    field(:ref_id, :string)
    field(:charge, :decimal)
    field(:delivery_fee, :decimal, default: Decimal.new(0.0))

    field(:state, :string, virtual: true)

    has_one(:invoice, SalesReg.Order.Invoice)
    has_one(:location, SalesReg.Business.Location)
    has_many(:items, SalesReg.Order.Item, on_replace: :delete)
    has_many(:reviews, SalesReg.Order.Review)
    has_many(:stars, SalesReg.Order.Star)

    belongs_to(:user, SalesReg.Accounts.User)
    belongs_to(:contact, SalesReg.Business.Contact)
    belongs_to(:company, SalesReg.Business.Company)
    belongs_to(:bonanza, SalesReg.SpecialOffer.Bonanza)

    timestamps()
  end

  @required_fields [
    :user_id,
    :contact_id,
    :company_id,
    :date,
    :ref_id,
    :charge
  ]

  @optional_fields [
    :status,
    :tax,
    :discount,
    :payment_method,
    :bonanza_id,
    :delivery_fee
  ]

  @number_fields [:discount, :charge, :delivery_fee]

  @doc false
  def changeset(sale, attrs) do
    new_attrs = Base.transform_string_keys_to_numbers(attrs, @number_fields)

    sale
    |> Repo.preload([:items, :location])
    |> cast(new_attrs, @required_fields ++ @optional_fields)
    |> before_update_callback(attrs)
    |> validate_required(@required_fields)
    |> cast_assoc(:items)
    |> cast_assoc(:location)
    |> assoc_constraint(:company)
    |> assoc_constraint(:user)
    |> assoc_constraint(:contact)
    # |> validate_payment_method()
    |> validate_inclusion(:status, @order_status)
    |> Base.validate_changeset_number_values(@number_fields)
  end

  # defp validate_payment_method(changeset) do
  #   case get_field(changeset, :payment_method) do
  #     "card" -> changeset
  #     "cash" -> changeset
  #     _ -> add_error(changeset, :payment_method, "Invalid payment method")
  #   end
  # end

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
    "#{Business.get_company_share_url(sale.company.slug)}/s/#{sale.id}"
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

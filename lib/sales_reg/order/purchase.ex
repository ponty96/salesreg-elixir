defmodule SalesReg.Order.Purchase do
  use Ecto.Schema
  import Ecto.Changeset
  alias SalesReg.Repo


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "purchases" do
    field :date, :string
    field :payment_method, :string
    field :purchasing_agent, :string
    field :status, :string
    field :amount, :string
    
    has_many :items, SalesReg.Order.Item, on_replace: :delete
    belongs_to :user, SalesReg.Accounts.User
    belongs_to :vendor, SalesReg.Business.Vendor

    timestamps()
  end

  @required_fields [
    :date, 
    :payment_method, 
    :purchasing_agent, 
    :status, 
    :amount, 
    :user_id, 
    :vendor_id
  ]

  @optional_fields []

  @doc false
  def changeset(purchase, attrs) do
    purchase
    |> Repo.preload([:items])
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> cast_assoc(:items)
  end
end

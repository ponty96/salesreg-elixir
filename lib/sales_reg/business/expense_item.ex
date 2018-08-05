defmodule SalesReg.Business.ExpenseItem do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "expense_items" do
    field(:item_name, :string)
    field(:amount, :string)
    
    belongs_to(:product, SalesReg.Store.Product)
    belongs_to(:service, SalesReg.Store.Service)
    belongs_to(:expense, SalesReg.Business.Expense, foreign_key: :expense_id)
    
    timestamps()
  end

  @required_fields [:item_name, :amount, :expense_id]
  @optional_fields [:product_id, :service_id]

  @doc false
  def changeset(expense_item, attrs) do
    expense_item
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> product_or_service_exist?()
  end

  def product_or_service_exist?(changeset) do
    product_id = get_field(changeset, :product_id)
    service_id = get_field(changeset, :service_id)

    cond do
      product_id != nil and service_id == nil -> 
        assoc_constraint(changeset, :product)
      
      service_id != nil and product_id == nil ->
        assoc_constraint(changeset, :service)
      
      true -> 
        add_error(changeset, [:product_id], "product_id or service_id must not be empty")
        add_error(changeset, [:service_id], "product_id or service_id must not be empty")
    end
  end
end

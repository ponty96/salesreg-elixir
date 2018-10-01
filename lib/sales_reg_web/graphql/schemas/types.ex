defmodule SalesRegWeb.GraphQL.Schemas.DataTypes do
  @moduledoc """
  	Module contains all GraphQL Object Types
  """

  use Absinthe.Schema.Notation
  use Absinthe.Ecto, repo: SalesReg.Repo
  use SalesRegWeb, :context
  import Absinthe.Resolution.Helpers

  alias SalesReg.Accounts.User
  alias Ecto.UUID

  import_types(Absinthe.Type.Custom)

  @desc """
    User object type
  """

  object :user do
    field(:id, :uuid)
    field(:date_of_birth, :string)
    field(:email, non_null(:string))
    field(:first_name, :string)
    field(:gender, :string)
    field(:last_name, :string)
    field(:profile_picture, :string)

    field(:inserted_at, :naive_datetime)
    field(:updated_at, :naive_datetime)
    field(:company, :company, resolve: dataloader(SalesReg.Business, :company))
  end

  @desc """
    Company object type
  """
  object :company do
    field(:id, :uuid)
    field(:about, :string)
    field(:contact_email, :string)
    field(:title, :string)
    field(:category, :string)
    field(:currency, :string)
    field(:description, :string)
    field(:logo, :string)

    field(:branches, list_of(:branch), resolve: dataloader(SalesReg.Business, :branches))
    field(:owner, :user, resolve: dataloader(SalesReg.Accounts, :owner))
    field(:phone, :phone, resolve: dataloader(SalesReg.Business, :phone))
  end

  @desc """
    Branch object type
  """
  object :branch do
    field(:id, :uuid)
    field(:type, :string)

    field(:company, :company, resolve: dataloader(SalesReg.Business, :company))
    field(:location, :location, resolve: dataloader(SalesReg.Business, :location))
  end

  @desc """
    Location object type
  """
  object :location do
    field(:id, :uuid)
    field(:city, :string)
    field(:country, :string)
    field(:lat, :string)
    field(:long, :string)
    field(:state, :string)
    field(:street1, :string)
    field(:street2, :string)
    field(:type, :string)
  end

  @desc """
    Product object type
  """
  object :product do
    field(:id, :uuid)
    field(:description, :string)
    field(:featured_image, :string)
    field(:name, :string)
    field(:stock_quantity, :string)
    field(:minimum_stock_quantity, :string)
    field(:cost_price, :string)
    field(:selling_price, :string)

    field(:company, :company, resolve: dataloader(SalesReg.Business, :company))
    field(:user, :user, resolve: dataloader(SalesReg.Accounts, :user))
  end

  @desc """
    Service object type
  """
  object :service do
    field(:id, :uuid)
    field(:description, :string)
    field(:name, :string)
    field(:price, :string)

    field(:company, :company, resolve: dataloader(SalesReg.Business, :company))
    field(:user, :user, resolve: dataloader(SalesReg.Accounts, :user))
  end

  @desc """
    Contact object type
  """
  object :contact do
    field(:id, :uuid)
    field(:image, :string)
    field(:contact_name, :string)
    field(:email, :string)
    field(:currency, :string)
    field(:birthday, :string)
    field(:marital_status, :string)
    field(:likes, list_of(:string))
    field(:dislikes, list_of(:string))
    field(:type, :string)
    field(:gender, :string)

    field(:address, :location, resolve: dataloader(SalesReg.Business, :address))
    field(:phone, :phone, resolve: dataloader(SalesReg.Business, :phone))
    field(:company, :company, resolve: dataloader(SalesReg.Business, :company))
    field(:user, :user, resolve: dataloader(SalesReg.Business, :user))
    field(:bank, :bank, resolve: dataloader(SalesReg.Business, :bank))
  end

  @desc """
    Phone object type
  """
  object :phone do
    field(:id, :uuid)
    field(:number, :string)
    field(:type, :string)
  end

  @desc """
    Purchase Order object type
  """
  object :purchase do
    field(:id, :uuid)
    field(:date, :string)
    field(:payment_method, :string)
    field(:purchasing_agent, :string)
    field(:status, :string)
    field(:amount, :string)
    field(:inserted_at, :naive_datetime)
    field(:updated_at, :naive_datetime)

    field(:user, :user, resolve: dataloader(SalesReg.Accounts, :user))
    field(:contact, :contact, resolve: dataloader(SalesReg.Business, :contact))
    field(:items, list_of(:item), resolve: dataloader(SalesReg.Order, :items))
    field(:company, :company, resolve: dataloader(SalesReg.Business, :company))
  end

  @desc """
    Item object type
  """
  object :item do
    field(:id, :uuid)
    field(:quantity, :string)
    field(:unit_price, :string)

    field(:product, :product, resolve: dataloader(SalesReg.Store, :product))
    field(:service, :service, resolve: dataloader(SalesReg.Store, :service))
  end

  @desc """
    Sale object type
  """
  object :sale do
    field(:id, :uuid)
    field(:date, :string)
    field(:status, :string)
    field(:payment_method, :string)
    field(:tax, :string)
    field(:amount, :string)
    field(:type, :string)
    field(:inserted_at, :naive_datetime)
    field(:updated_at, :naive_datetime)

    field(:user, :user, resolve: dataloader(SalesReg.Accounts, :user))
    field(:contact, :contact, resolve: dataloader(SalesReg.Business, :contact))
    field(:items, list_of(:item), resolve: dataloader(SalesReg.Order, :items))
    field(:company, :company, resolve: dataloader(SalesReg.Business, :company))
    field(:phone, :phone, resolve: dataloader(SalesReg.Business, :phone))
  end

  object :bank do
    field(:id, :uuid)
    field(:account_name, :string)
    field(:account_number, :string)
    field(:bank_name, :string)

    field(:contact, :contact, resolve: dataloader(SalesReg.Business, :contact))
  end

  @desc """
    Expense object type
  """
  object :expense do
    field(:id, :uuid)
    field(:title, :string)
    field(:date, :string)
    field(:total_amount, :float)
    field(:payment_method, :string)

    field(:paid_by, :user, resolve: dataloader(SalesReg.Accounts, :paid_by))
    field(:company, :company, resolve: dataloader(SalesReg.Business, :company))

    field(
      :expense_items,
      list_of(:expense_item),
      resolve: dataloader(SalesReg.Business, :expense_items)
    )
  end

  @desc """
    Expense Item object type
  """
  object :expense_item do
    field(:id, :uuid)
    field(:item_name, :string)
    field(:amount, :float)

    field(:expense, :expense, resolve: dataloader(SalesReg.Business, :expense))
  end

  @desc """
    Consistent Type for Mutation Response
  """
  object :mutation_response do
    field(:success, non_null(:boolean))
    field(:field_errors, list_of(:error))
    field(:data, :mutated_data)
  end

  union :mutated_data do
    description("A mutated data")

    types([
      :user,
      :authorization,
      :company,
      :branch,
      :product,
      :service,
      :contact,
      :phone,
      :location,
      :purchase,
      :item,
      :sale,
      :expense
    ])

    resolve_type(fn
      %User{}, _ -> :user
      %Company{}, _ -> :company
      %Branch{}, _ -> :branch
      %Product{}, _ -> :product
      %Service{}, _ -> :service
      %Contact{}, _ -> :contact
      %Phone{}, _ -> :phone
      %Location{}, _ -> :location
      %Purchase{}, _ -> :purchase
      %Item{}, _ -> :item
      %Sale{}, _ -> :sale
      %{user: %User{}}, _ -> :authorization
      %Expense{}, _ -> :expense
    end)
  end

  object :error do
    field(:message, :string)
    field(:key, non_null(:string))
  end

  object :authorization do
    field(:access_token, :string)
    field(:refresh_token, :string)
    field(:message, :string)
    field(:user, non_null(:user))
  end

  @desc """
    Product or Service search response
  """
  object :search_response do
    field(:id, non_null(:uuid))
    field(:name, non_null(:string))
  end

  @desc "sorts the order from either ASC or DESC"
  enum :gender do
    value(:male, as: "MALE")
    value(:female, as: "FEMALE")
  end

  @desc "sorts the order from either ASC or DESC"
  enum :order_status do
    value(:pending, as: "pending")
    value(:processed, as: "processed")
    value(:delivering, as: "delivering")
    value(:recalled, as: "delivered | recalled")
    value(:delivered, as: "delivered")
  end

  @desc "The selected company category"
  enum :category do
    value(:product, as: "product", description: "Product")
    value(:service, as: "service", description: "Service")
    value(:product_service, as: "product_service", description: "Product and Service")
  end

  @desc "Payment method types"
  enum :payment_method do
    value(:pos, as: "POS")
    value(:cheque, as: "cheque")
    value(:direct_transfer, as: "direct transfer")
    value(:cash, as: "cash")
  end

  @desc "UUID is a scalar macro that checks if id is a valid uuid"
  scalar :uuid do
    parse(fn input ->
      with %Absinthe.Blueprint.Input.String{value: value} <- input,
           {:ok, uuid} <- UUID.cast(value) do
        {:ok, uuid}
      else
        _ ->
          :error
      end
    end)

    serialize(&check_uuid/1)
  end

  def check_uuid(uuid) do
    case UUID.cast(uuid) do
      {:ok, uuid} -> uuid
      _ -> :error
    end
  end

  #
  # INPUT OBJECTS
  #
  input_object :user_input do
    field(:date_of_birth, :string)
    field(:email, non_null(:string))
    field(:first_name, non_null(:string))
    field(:gender, non_null(:gender))
    field(:last_name, non_null(:string))
    field(:password, non_null(:string))
    field(:password_confirmation, non_null(:string))
    field(:profile_picture, :string)
  end

  input_object :update_user_input do
    field(:date_of_birth, non_null(:string))
    field(:first_name, non_null(:string))
    field(:gender, non_null(:gender))
    field(:last_name, non_null(:string))
    field(:profile_picture, :string)
  end

  input_object :company_input do
    field(:title, non_null(:string))
    field(:about, :string)
    field(:contact_email, non_null(:string))
    field(:head_office, non_null(:location_input))
    field(:category, non_null(:category))
    field(:currency, :string)
    field(:description, :string)
    field(:phone, :phone_input)
    field(:logo, :string)
  end

  input_object :branch_input do
    field(:type, :string)
    field(:company_id, non_null(:uuid))
    field(:location, non_null(:location_input))
  end

  input_object :location_input do
    field(:city, non_null(:string))
    field(:country, non_null(:string))
    field(:lat, :string)
    field(:long, :string)
    field(:state, non_null(:string))
    field(:street1, non_null(:string))
    field(:street2, :string)
    field(:type, :string)
  end

  input_object :phone_input do
    field(:number, non_null(:string))
    field(:type, :string)
  end

  input_object :product_input do
    field(:description, :string)
    field(:featured_image, :string)
    field(:name, non_null(:string))
    field(:stock_quantity, non_null(:string))
    field(:minimum_stock_quantity, non_null(:string))
    field(:cost_price, non_null(:string))
    field(:selling_price, non_null(:string))

    field(:company_id, non_null(:uuid))
    field(:user_id, non_null(:uuid))
  end

  input_object :service_input do
    field(:description, :string)
    field(:name, non_null(:string))
    field(:price, :string)

    field(:company_id, non_null(:uuid))
    field(:user_id, non_null(:uuid))
  end

  input_object :contact_input do
    field(:image, :string)
    field(:contact_name, non_null(:string))
    field(:phone, non_null(:phone_input))
    field(:address, non_null(:location_input))
    field(:email, non_null(:string))
    field(:currency, non_null(:string))
    field(:birthday, non_null(:string))
    field(:marital_status, non_null(:string))
    field(:marriage_anniversary, :string)
    field(:likes, non_null(list_of(:string)))
    field(:dislikes, non_null(list_of(:string)))
    field(:bank, :bank_input)
    field(:gender, non_null(:gender))

    field(:type, non_null(:string))

    field(:company_id, :uuid)
    field(:user_id, non_null(:uuid))
  end

  input_object :purchase_input do
    field(:date, non_null(:string))
    field(:payment_method, non_null(:payment_method))
    field(:purchasing_agent, :string)
    field(:items, non_null(list_of(:item_input)))

    field(:user_id, non_null(:uuid))
    field(:contact_id, non_null(:uuid))
    field(:company_id, non_null(:uuid))
    field(:amount, non_null(:string))
    field(:status, non_null(:order_status))
  end

  input_object :item_input do
    field(:product_id, :uuid)
    field(:service_id, :uuid)
    field(:quantity, non_null(:string))
    field(:unit_price, non_null(:string))
  end

  input_object :sale_input do
    field(:date, non_null(:string))
    field(:items, non_null(list_of(:item_input)))
    field(:payment_method, non_null(:payment_method))
    field(:tax, :string)

    field(:amount, non_null(:string))

    field(:user_id, non_null(:uuid))
    field(:contact_id, non_null(:uuid))
    field(:company_id, non_null(:uuid))

    field(:status, non_null(:order_status))
  end

  input_object :bank_input do
    field(:account_name, non_null(:string))
    field(:account_number, non_null(:string))
    field(:bank_name, non_null(:string))
  end

  input_object :expense_input do
    field(:title, non_null(:string))
    field(:date, non_null(:string))
    field(:payment_method, non_null(:payment_method))
    field(:expense_items, non_null(list_of(:expense_item_input)))
    field(:paid_by_id, non_null(:uuid))
    field(:company_id, non_null(:uuid))
    field(:total_amount, non_null(:float))
  end

  input_object :expense_item_input do
    field(:item_name, non_null(:string))
    field(:amount, non_null(:float))
  end

  #########################################################
  # These are used only at the point of updating the
  # ID has to be supplied except for parent input objects
  #########################################################

  input_object :update_location_input do
    field(:id, non_null(:uuid))
    field(:city, non_null(:string))
    field(:country, non_null(:string))
    field(:lat, :string)
    field(:long, :string)
    field(:state, non_null(:string))
    field(:street1, non_null(:string))
    field(:street2, :string)
  end

  input_object :update_phone_input do
    field(:id, non_null(:uuid))
    field(:number, non_null(:string))
  end
end

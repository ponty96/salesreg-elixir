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

    field(:employees, list_of(:employee), resolve: dataloader(SalesReg.Business, :employees))
    field(:branches, list_of(:branch), resolve: dataloader(SalesReg.Business, :branches))
    field(:vendors, list_of(:vendor), resolve: dataloader(SalesReg.Business, :vendor))
    field(:owner, :user, resolve: dataloader(SalesReg.Accounts, :owner))
  end

  @desc """
    Branch object type
  """
  object :branch do
    field(:id, :uuid)
    field(:type, :string)

    field(:company, :company, resolve: dataloader(SalesReg.Business, :company))
    field(:employees, list_of(:employee), resolve: dataloader(SalesReg.Business, :employees))
    field(:location, :location, resolve: dataloader(SalesReg.Business, :location))
  end

  @desc """
    Employee object type
  """
  object :employee do
    field(:id, :uuid)
    field(:person, :user, resolve: dataloader(SalesReg.Accounts, :person))

    field(:employer, :company, resolve: dataloader(SalesReg.Business, :employer))
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
    field(:pack_quantity, :string)
    field(:price_per_pack, :string)
    field(:selling_price, :string)
    field(:unit_quantity, :string)

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
    Customer object type
  """
  object :customer do
    field(:id, :uuid)
    field(:image, :string)
    field(:customer_name, :string)
    field(:email, :string)
    field(:fax, :string)
    field(:city, :string)
    field(:state, :string)
    field(:country, :string)

    field(:residential_add, :location, resolve: dataloader(SalesReg.Business, :residential_add))
    field(:office_add, :location, resolve: dataloader(SalesReg.Business, :office_add))
    field(:phones, list_of(:phone), resolve: dataloader(SalesReg.Business, :phones))
    field(:company, :company, resolve: dataloader(SalesReg.Business, :company))
    field(:user, :user, resolve: dataloader(SalesReg.Business, :user))
  end

  @desc """
    Vendor object type
  """
  object :vendor do
    field(:id, :uuid)
    field(:email, :string)
    field(:fax, :string)
    field(:city, :string)
    field(:state, :string)
    field(:country, :string)
    field(:currency, :string)

    field(:company, :company, resolve: dataloader(SalesReg.Business, :company))
    field(:location, list_of(:location), resolve: dataloader(SalesReg.Business, :location))
    field(:user, :user, resolve: dataloader(SalesReg.Accounts, :user))
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
      :employee,
      :branch,
      :product,
      :service,
      :vendor,
      :customer,
      :phone,
      :location
    ])

    resolve_type(fn
      %User{}, _ -> :user
      %Company{}, _ -> :company
      %Employee{}, _ -> :employee
      %Branch{}, _ -> :branch
      %Product{}, _ -> :product
      %Service{}, _ -> :service
      %Customer{}, _ -> :customer
      %Phone{}, _ -> :phone
      %Location{}, _ -> :location
      %Vendor{}, _ -> :vendor
      %{user: %User{}}, _ -> :authorization
    end)
  end

  object :error do
    field(:message, :string)
    field(:key, non_null(:string))
  end

  object :authorization do
    field(:jwt, non_null(:string))
    field(:user, non_null(:user))
  end

  @desc "sorts the order from either ASC or DESC"
  enum :gender do
    value(:male)
    value(:female)
  end

  @desc "The selected company category"
  enum :category do
    value(:product, as: "product", description: "Product")
    value(:service, as: "service", description: "Service")
    value(:product_service, as: "product_service", description: "Product and Service")
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

  input_object :company_input do
    field(:title, non_null(:string))
    field(:about, non_null(:string))
    field(:contact_email, non_null(:string))
    field(:head_office, non_null(:location_input))
    field(:category, non_null(:category))
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
    field(:type, non_null(:string))
  end

  input_object :phone_input do
    field(:number, non_null(:string))
  end

  input_object :product_input do
    field(:description, :string)
    field(:featured_image, :string)
    field(:name, non_null(:string))
    field(:pack_quantity, :string)
    field(:price_per_pack, :string)
    field(:selling_price, non_null(:string))
    field(:unit_quantity, :string)

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

  input_object :customer_input do
    field(:image, :string)
    field(:customer_name, non_null(:string))
    field(:phones, non_null(list_of(:phone_input)))
    field(:residential_add, non_null(:location_input))
    field(:office_add, non_null(:location_input))
    field(:email, non_null(:string))
    field(:fax, :string)
    field(:city, :string)
    field(:state, :string)
    field(:country, :string)

    field(:company_id, non_null(:uuid))
    field(:user_id, non_null(:uuid))
  end

  input_object :vendor_input do
    field(:email, non_null(:string))
    field(:fax, non_null(:string))
    field(:city, non_null(:string))
    field(:state, non_null(:string))
    field(:country, non_null(:string))
    field(:currency, non_null(:string))
    field(:locations, non_null(list_of(:location_input)))

    field(:company_id, non_null(:uuid))
    field(:user_id, non_null(:uuid))
  end

  #########################################################
  # These are used only at the point of updating the
  # ID has to be supplied except for parent input objects
  #########################################################
  input_object :update_customer_input do
    field(:image, :string)
    field(:customer_name, non_null(:string))
    field(:phones, non_null(list_of(:update_phone_input)))
    field(:residential_add, non_null(:update_location_input))
    field(:office_add, non_null(:update_location_input))
    field(:email, non_null(:string))
    field(:fax, :string)
    field(:city, :string)
    field(:state, :string)
    field(:country, :string)

    field(:company_id, non_null(:uuid))
    field(:user_id, non_null(:uuid))
  end

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

  input_object :update_vendor_input do
    field(:email, non_null(:string))
    field(:fax, non_null(:string))
    field(:city, non_null(:string))
    field(:state, non_null(:string))
    field(:country, non_null(:string))
    field(:currency, non_null(:string))
    field(:locations, non_null(list_of(:update_location_input)))

    field(:company_id, non_null(:uuid))
    field(:user_id, non_null(:uuid))
  end
end

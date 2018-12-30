defmodule SalesRegWeb.GraphQL.DataTypes do
  @moduledoc """
  	Module contains all GraphQL Object Types
  """

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :classic
  use SalesRegWeb, :graphql_context
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
    field(:currency, :string)
    field(:description, :string)
    field(:logo, :string)
    field(:cover_photo, :string)
    field(:slug, :string)

    field(:branches, list_of(:branch), resolve: dataloader(SalesReg.Business, :branches))
    field(:owner, :user, resolve: dataloader(SalesReg.Accounts, :owner))
    field(:phone, :phone, resolve: dataloader(SalesReg.Business, :phone))
    field(:bank, :bank, resolve: dataloader(SalesReg.Business, :bank))
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
    Product Group object type
  """
  object :product_group do
    field(:id, :uuid)
    field(:title, :string)

    field(:products, list_of(:product), resolve: dataloader(SalesReg.Store, :products))
    field(:options, list_of(:option), resolve: dataloader(SalesReg.Store, :options))
  end

  @desc """
    Option object type
  """
  object :option do
    field(:id, :uuid)
    field(:name, :string)

    field(:option_values, list_of(:option_value),
      resolve: dataloader(SalesReg.Store, :option_values)
    )

    field(:product_groups, list_of(:product_group),
      resolve: dataloader(SalesReg.Store, :product_groups)
    )
  end

  connection(node_type: :option)

  @desc """
    Product object type
  """
  object :product do
    field(:id, :uuid)
    field(:description, :string)

    field :name, :string do
      resolve(fn _parent, %{source: product} ->
        name = Store.get_product_name(product)
        {:ok, name}
      end)
    end

    field(:sku, :string)
    field(:minimum_sku, :string)
    field(:cost_price, :string)
    field(:price, :string)

    field(:featured_image, :string)
    field(:images, list_of(:string))

    field(:is_featured, :boolean)
    field(:is_top_rated_by_merchant, :boolean)

    field(:categories, list_of(:category), resolve: dataloader(SalesReg.Store, :categories))
    field(:tags, list_of(:tag), resolve: dataloader(SalesReg.Store, :tags))

    field(:option_values, list_of(:option_value),
      resolve: dataloader(SalesReg.Store, :option_values)
    )

    field(:product_group, :product_group, resolve: dataloader(SalesReg.Store, :product_group))

    field(:reviews, list_of(:review), resolve: dataloader(SalesReg.Order, :reviews))
    field(:stars, list_of(:star), resolve: dataloader(SalesReg.Order, :stars))

    field(:company, :company, resolve: dataloader(SalesReg.Business, :company))
    field(:user, :user, resolve: dataloader(SalesReg.Accounts, :user))

    field :total_quantity_sold, :integer do
      resolve(fn _parent, %{source: product} ->
        quantity_sold = Order.calc_product_total_quantity_sold(product.id)
        {:ok, quantity_sold}
      end)
    end
  end

  connection(node_type: :product)

  @desc """
    Option Value Object Type
  """
  object :option_value do
    field(:id, :uuid)
    field(:name, :string)

    field(:option, :option, resolve: dataloader(SalesReg.Store, :option))
    field(:product, :product, resolve: dataloader(SalesReg.Store, :product))
  end

  @desc """
    Service object type
  """
  object :service do
    field(:id, :uuid)
    field(:description, :string)
    field(:name, :string)
    field(:price, :string)
    field(:featured_image, :string)
    field(:images, list_of(:string))
    field(:is_featured, :boolean)
    field(:is_top_rated_by_merchant, :boolean)
    field(:categories, list_of(:category), resolve: dataloader(SalesReg.Store, :categories))
    field(:tags, list_of(:tag), resolve: dataloader(SalesReg.Store, :tags))

    field(:company, :company, resolve: dataloader(SalesReg.Business, :company))
    field(:user, :user, resolve: dataloader(SalesReg.Accounts, :user))

    field(:reviews, list_of(:review), resolve: dataloader(SalesReg.Order, :reviews))
    field(:stars, list_of(:star), resolve: dataloader(SalesReg.Order, :stars))

    field :total_times_ordered, :integer do
      resolve(fn _parent, %{source: service} ->
        quantity_ordered = Order.calc_service_total_times_ordered(service.id)
        {:ok, quantity_ordered}
      end)
    end
  end

  connection(node_type: :service)

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
    field(:instagram, :string)
    field(:twitter, :string)
    field(:facebook, :string)
    field(:snapchat, :string)
    field(:allows_marketing, :string)

    field :total_debt, :float do
      resolve(fn _parent, %{source: contact} ->
        {:ok, Order.contact_orders_debt(contact)}
      end)
    end

    # total sales made by merchant to customer
    field :total_amount_paid, :float do
      resolve(fn _parent, %{source: contact} ->
        {:ok, Order.contact_total_amount_paid(contact)}
      end)
    end

    field(:address, :location, resolve: dataloader(SalesReg.Business, :address))
    field(:phone, :phone, resolve: dataloader(SalesReg.Business, :phone))
    field(:company, :company, resolve: dataloader(SalesReg.Business, :company))
    field(:user, :user, resolve: dataloader(SalesReg.Business, :user))

    field(:inserted_at, :naive_datetime)
    field(:updated_at, :naive_datetime)
  end

  connection(node_type: :contact)

  @desc """
    Phone object type
  """
  object :phone do
    field(:id, :uuid)
    field(:number, :string)
    field(:type, :string)
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
    field(:ref_id, :string)

    field :amount, :float do
      resolve(fn _parent, %{source: sale} ->
        {:ok, Order.calc_order_amount(sale)}
      end)
    end

    field :amount_paid, :float do
      resolve(fn _parent, %{source: sale} ->
        {:ok, Order.calc_order_amount_paid(sale)}
      end)
    end

    field(:discount, :string)
    field(:type, :string)
    field(:inserted_at, :naive_datetime)
    field(:updated_at, :naive_datetime)

    field(:user, :user, resolve: dataloader(SalesReg.Accounts, :user))
    field(:contact, :contact, resolve: dataloader(SalesReg.Business, :contact))
    field(:items, list_of(:item), resolve: dataloader(SalesReg.Order, :items))
    field(:company, :company, resolve: dataloader(SalesReg.Business, :company))
    field(:phone, :phone, resolve: dataloader(SalesReg.Business, :phone))
    field(:invoice, :invoice, resolve: dataloader(SalesReg.Order, :invoice))
  end

  connection(node_type: :sale)

  object :bank do
    field(:id, :uuid)
    field(:account_name, :string)
    field(:account_number, :string)
    field(:bank_name, :string)
    field(:is_primary, :boolean)

    field(:inserted_at, :naive_datetime)
    field(:updated_at, :naive_datetime)

    field(:company, :company, resolve: dataloader(SalesReg.Business, :company))
  end

  connection(node_type: :bank)

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

  connection(node_type: :expense)

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
    Category object Type
  """
  object :category do
    field(:id, :uuid)
    field(:description, :string)
    field(:title, :string)
    field(:company, :company, resolve: dataloader(SalesReg.Business, :company))
    field(:user, :user, resolve: dataloader(SalesReg.Accounts, :user))

    field(
      :products,
      list_of(:product),
      resolve: dataloader(SalesReg.Business, :products)
    )

    field(
      :services,
      list_of(:service),
      resolve: dataloader(SalesReg.Business, :services)
    )

    field :image, :string do
      resolve(fn _parent, %{source: category} ->
        {:ok, Store.category_image(category)}
      end)
    end
  end

  connection(node_type: :category)

  @desc """
    Tag object Type
  """
  object :tag do
    field(:id, :uuid)
    field(:name, :string)

    field(:company, :company, resolve: dataloader(SalesReg.Business, :company))
  end

  connection(node_type: :tag)

  @desc """
    Invoice object Type
  """
  object :invoice do
    field(:id, :uuid)
    field(:due_date, :string)
    field(:ref_id, :string)

    field :amount, :float do
      resolve(fn _parent, %{source: invoice} ->
        {:ok, Order.calc_order_amount(invoice)}
      end)
    end

    field :amount_paid, :float do
      resolve(fn _parent, %{source: invoice} ->
        {:ok, Order.calc_order_amount_paid(invoice)}
      end)
    end

    field(:company, :company, resolve: dataloader(SalesReg.Business, :company))
    field(:user, :user, resolve: dataloader(SalesReg.Accounts, :user))
    field(:sale, :sale, resolve: dataloader(SalesReg.Order, :sale))
  end

  connection(node_type: :invoice)

  @desc """
    Review object type
  """
  object :review do
    field(:id, :uuid)
    field(:text, :string)

    field(:sale, :sale, resolve: dataloader(SalesReg.Order, :sale))
    field(:product, :product, resolve: dataloader(SalesReg.Store, :product))
    field(:service, :service, resolve: dataloader(SalesReg.Store, :service))
    field(:contact, :contact, resolve: dataloader(SalesReg.Business, :contact))
  end

  @desc """
    Star object type
  """
  object :star do
    field(:id, :uuid)
    field(:value, :integer)

    field(:sale, :sale, resolve: dataloader(SalesReg.Order, :sale))
    field(:product, :product, resolve: dataloader(SalesReg.Store, :product))
    field(:service, :service, resolve: dataloader(SalesReg.Store, :service))
    field(:contact, :contact, resolve: dataloader(SalesReg.Business, :contact))
  end

  @desc """
    Receipt object Type
  """
  object :receipt do
    field(:id, :uuid)
    field(:amount_paid, :string)
    field(:time_paid, :string)
    field(:payment_method, :payment_method)
    field(:pdf_url, :string)
    field(:reference_id, :string)
    field(:ref_id, :string)

    field(:invoice, :invoice, resolve: dataloader(SalesReg.Order, :invoice))
    field(:company, :company, resolve: dataloader(SalesReg.Business, :company))
    field(:user, :user, resolve: dataloader(SalesReg.Accounts, :user))
    field(:sale, :sale, resolve: dataloader(SalesReg.Order, :sale))
  end

  @desc """
    Template object type
  """
  object :template do
    field(:id, :uuid)
    field(:title, :string)
    field(:slug, :string)
    field(:featured_image, :string)
  end

  connection(node_type: :template)

  @desc """
    CompanyTemplate object type
  """
  object :company_template do
    field(:id, :uuid)
    field(:status, :string)

    field(:template, list_of(:template), resolve: dataloader(SaleReg.Theme, :template))
    field(:user, :user, resolve: dataloader(SalesReg.Accounts, :user))
    field(:company, :company, resolve: dataloader(SalesReg.Business, :company))
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
      :item,
      :sale,
      :expense,
      :category,
      :tag,
      :bank,
      :review,
      :star,
      :receipt,
      :invoice,
      :product_group,
      :option,
      :template,
      :company_template
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
      %Item{}, _ -> :item
      %Sale{}, _ -> :sale
      %{user: %User{}}, _ -> :authorization
      %Expense{}, _ -> :expense
      %Category{}, _ -> :category
      %Tag{}, _ -> :tag
      %Bank{}, _ -> :bank
      %Review{}, _ -> :review
      %Star{}, _ -> :star
      %Receipt{}, _ -> :receipt
      %Invoice{}, _ -> :invoice
      %ProductGroup{}, _ -> :product_group
      %Option{}, _ -> :option
      %Template{}, _ -> :template
      %CompanyTemplate{}, _ -> :company_template
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
    field(:price, :string)
    field(:cost_price, :string)
    field(:type, :string)
    field(:sku, :string)
  end

  @desc "sorts the order from either ASC or DESC"
  enum :gender do
    value(:male, as: "MALE")
    value(:female, as: "FEMALE")
  end

  @desc "sorts the order from either ASC or DESC"
  enum :company_template_status do
    value(:active, as: "ACTIVE")
    value(:inactive, as: "INACTIVE")
  end

  @desc "sorts the order from either ASC or DESC"
  enum :order_status do
    value(:pending, as: "pending")
    value(:processed, as: "processed")
    value(:delivering, as: "delivering")
    value(:recalled, as: "delivered | recalled")
    value(:delivered, as: "delivered")
  end

  @desc "Payment method types"
  enum :payment_method do
    value(:cash, as: "cash")
    value(:card, as: "card")
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
    field(:currency, non_null(:string))
    field(:description, :string)
    field(:phone, :phone_input)
    field(:logo, :string)
    field(:slug, non_null(:string))
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

  input_object :product_group_input do
    field(:product_group_id, :uuid)
    field(:product_group_title, :string)
    field(:company_id, non_null(:uuid))

    field(:product, non_null(:product_input))
  end

  input_object :product_input do
    field(:id, :uuid)
    field(:description, :string)
    field(:name, :string)
    field(:sku, non_null(:string))
    field(:minimum_sku, non_null(:string))
    field(:cost_price, :string)
    field(:price, non_null(:string))
    field(:images, list_of(:string))
    field(:company_id, non_null(:uuid))
    field(:user_id, non_null(:uuid))
    field(:categories, list_of(:uuid), default_value: [])
    field(:tags, list_of(:string), default_value: [])

    field(:featured_image, non_null(:string))
    field(:images, list_of(:string))

    field(:is_featured, :boolean)
    field(:is_top_rated_by_merchant, :boolean)

    field(:option_values, list_of(:option_value_input), default_value: [])
  end

  input_object :option_value_input do
    field(:name, :string)
    field(:option_id, non_null(:uuid))
    field(:company_id, non_null(:uuid))
  end

  input_object :option_input do
    field(:name, non_null(:string))
    field(:company_id, non_null(:uuid))
  end

  input_object :service_input do
    field(:description, :string)
    field(:name, non_null(:string))
    field(:price, :string)

    field(:company_id, non_null(:uuid))
    field(:user_id, non_null(:uuid))
    field(:categories, list_of(:uuid), default_value: [])
    field(:tags, list_of(:string), default_value: [])

    field(:featured_image, non_null(:string))
    field(:images, list_of(:string))

    field(:is_featured, :boolean)
    field(:is_top_rated_by_merchant, :boolean)
  end

  input_object :contact_input do
    field(:image, :string)
    field(:contact_name, non_null(:string))
    field(:phone, non_null(:phone_input))
    field(:address, non_null(:location_input))
    field(:email, non_null(:string))
    field(:gender, non_null(:gender))

    field(:type, non_null(:string))

    field(:company_id, non_null(:uuid))
    field(:user_id, non_null(:uuid))

    field(:allows_marketing, :string)
    field(:currency, :string)
    field(:birthday, :string)
    field(:marital_status, :string)
    field(:marriage_anniversary, :string)
    field(:likes, list_of(:string))
    field(:dislikes, list_of(:string))
    field(:instagram, :string)
    field(:twitter, :string)
    field(:facebook, :string)
    field(:snapchat, :string)
  end

  input_object :through_order_contact_input do
    field(:contact_name, non_null(:string))
    field(:email, non_null(:string))
    field(:company_id, non_null(:uuid))
    field(:user_id, non_null(:uuid))
    field(:type, non_null(:string))
    field(:address, :location_input)
  end

  input_object :restock_item_input do
    field(:product_id, :uuid)
    field(:quantity, non_null(:string))
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
    field(:discount, :string)
    field(:amount_paid, :string)
    field(:contact, :through_order_contact_input)

    field(:user_id, non_null(:uuid))
    field(:contact_id, :uuid)
    field(:company_id, non_null(:uuid))
  end

  input_object :bank_input do
    field(:account_name, :string)
    field(:account_number, non_null(:string))
    field(:bank_name, non_null(:string))
    field(:is_primary, :boolean)
    field(:company_id, non_null(:uuid))
  end

  input_object :expense_input do
    field(:title, non_null(:string))
    field(:date, non_null(:string))
    field(:payment_method, non_null(:payment_method))
    field(:expense_items, list_of(:expense_item_input))
    field(:paid_by_id, non_null(:uuid))
    field(:company_id, non_null(:uuid))
    field(:total_amount, non_null(:string))
  end

  input_object :expense_item_input do
    field(:item_name, non_null(:string))
    field(:amount, non_null(:string))
  end

  input_object :category_input do
    field(:description, :string)
    field(:title, non_null(:string))
    field(:user_id, non_null(:uuid))
    field(:company_id, non_null(:uuid))
  end

  input_object :invoice_input do
    field(:due_date, non_null(:string))
  end

  input_object :review_input do
    field(:text, non_null(:string))
    field(:product_id, :uuid)
    field(:service_id, :uuid)
    field(:contact_id, non_null(:uuid))
    field(:sale_id, non_null(:uuid))
  end

  input_object :star_input do
    field(:value, non_null(:integer))
    field(:product_id, :uuid)
    field(:service_id, :uuid)
    field(:contact_id, non_null(:uuid))
    field(:sale_id, non_null(:uuid))
  end

  input_object :receipt_input do
    field(:amount_paid, non_null(:string))
    field(:payment_method, non_null(:payment_method))
    field(:invoice_id, non_null(:uuid))
    field(:user_id, non_null(:uuid))
    field(:company_id, non_null(:uuid))
    field(:sale_id, non_null(:uuid))
    field(:reference_id, :string)
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

  ###
  # DATA SPECIFIC TO THE WEBSOTE
  ##
  object :home_data do
    field(:categories, list_of(:category))
    field(:featured_products, list_of(:product))
    field(:featured_services, list_of(:service))
    field(:company, :company)
  end

  object :product_page do
    field(:product_group, :product_group)
    field(:related_products, list_of(:product))
    field(:company, :company)
  end

  object :service_page do
    field(:service, :service)
    field(:related_services, list_of(:service))
    field(:company, :company)
  end

  object :category_page do
    field(:category, :category)
    field(:related_services, list_of(:service))
    field(:related_products, list_of(:product))
    field(:company, :company)
  end
end

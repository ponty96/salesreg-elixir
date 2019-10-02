defmodule SalesReg.Seed do
  @moduledoc """
  Seed Module
  """
  use SalesRegWeb, :context

  alias Faker.Address
  alias Faker.Avatar
  alias Faker.Commerce
  alias Faker.Commerce.En, as: CommerceEn
  alias Faker.Company.En, as: CompanyEn
  alias Faker.Date, as: FakerDate
  alias Faker.Industry
  alias Faker.Internet
  alias Faker.Name
  alias Faker.Name.En, as: NameEn
  alias Faker.Phone.EnGb

  @location_types ["office", "home"]
  @phone_types ["home", "mobile", "work"]
  @marital_status ["Single", "Married", "Widowed"]
  @banks ["076", "011", "063", "058"]
  @likes ["honesty", "integrity", "principled"]
  @dislikes ["lies", "pride", "laziness"]
  @payment_method ["cash", "card"]
  @seed_order_status ["pending", "processed", "delivering"]
  @gender ["MALE", "FEMALE"]

  def create_user do
    user_params = %{
      "date_of_birth" => "15-08-1991",
      "email" => "ayo.aregbede@gmail.com",
      "first_name" => "Samson",
      "gender" => "Male",
      "last_name" => "Oluwole",
      "password" => "asdfasdf",
      "password_confirmation" => "asdfasdf"
    }

    Accounts.create_user(user_params)
  end

  def create_company(user_id) do
    company_params = %{
      about: "Sales of Mobile Devices",
      contact_email: "ayo.aregbede@yipcart.com",
      title: "Sandbox PLC",
      head_office: gen_location_params(),
      currency: "NGN",
      description: "Sandbox is basically into sales
       of Mobiles devices and related assessories of specific brands which
       include Samsung, Apple, Sony, Tecno, Infinix and Nokia. It also provides
       numerous services",
      logo:
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTTulsnrbHjdztPnDwdWzruyJ-p1gi7Mwf43hT7cC1oiwl1hU_h",
      slug: "Sandbox",
      facebook: "http://facebook.com/officialsandbox",
      instagram: "http://instagram.com/officialsandbox",
      twitter: "http://twitter.com/officialsandbox",
      linkedin: "http://linkedin.com/officialsandbox",
      phone: gen_phone_params()
    }

    Business.create_company(user_id, company_params)
  end

  def add_contact(user_id, company_id, type) do
    contact_params = %{
      "contact_name" => "Desmond",
      "email" => "desmond1994@gmail.com",
      "user_id" => user_id,
      "company_id" => company_id,
      "marital_status" => "#{Enum.random(@marital_status)}",
      "marriage_anniversary" => past_date(:marr_anni),
      "gender" => Enum.random(@gender),
      "likes" => @likes,
      "dislikes" => @dislikes,
      "type" => type
    }

    Business.add_contact(contact_params)
  end

  def add_expense(user_id, company_id) do
    expenses_items = expenses_items()

    expense_params = %{
      "title" => "#{Industry.industry()} expense",
      "date" => past_date(:recent),
      "total_amount" => total_expense_cost(expenses_items),
      "paid_by_id" => user_id,
      "company_id" => company_id,
      "payment_method" => "Cash",
      "expense_items" => expenses_items,
      "items_amount" => total_expense_cost(expenses_items)
    }

    Business.add_expense(expense_params)
  end

  def create_bank(company_id) do
    gen_bank_details()
    |> Map.put_new(:company_id, company_id)
    |> Business.create_bank()
  end

  def create_receipt(invoice_id, user_id, company_id, sale_id) do
    current_date = Date.utc_today() |> Date.to_string()

    invoice_id
    |> gen_receipt_details(user_id, company_id)
    |> Map.put_new(:time_paid, current_date)
    |> Map.put_new(:sale_id, sale_id)
    |> Order.add_receipt()
  end

  defp total_expense_cost(expense_items) do
    Enum.sum(Enum.map(expense_items, fn expense_item -> expense_item["amount"] end))
  end

  defp expenses_items do
    Enum.map(1..5, fn _index ->
      %{
        "item_name" => CommerceEn.product_name_product(),
        "amount" => Enum.random([10_000.00, 50_000.00, 150_000.00])
      }
    end)
  end

  defp gen_location_params do
    %{
      "city" => Address.city(),
      "country" => Address.country(),
      "state" => Address.state(),
      "lat" => "#{Address.latitude()}",
      "long" => "#{Address.longitude()}",
      "street1" => Address.street_address(),
      "street2" => Address.street_address(),
      "type" => Enum.random(@location_types)
    }
  end

  defp gen_phone_params do
    %{
      "number" => "#{EnGb.mobile_number()}",
      "type" => Enum.random(@phone_types)
    }
  end

  def gen_bank_details do
    %{
      account_name: NameEn.name(),
      account_number: "#{Enum.random(0_152_637_490..0_163_759_275)}",
      bank_name: "#{Enum.random(@banks)}",
      is_primary: false
    }
  end

  def gen_receipt_details(invoice_id, user_id, company_id) do
    %{
      amount_paid: "#{Enum.random([1000, 2000, 3000])}",
      payment_method: "#{Enum.random(@payment_method)}",
      invoice_id: invoice_id,
      user_id: user_id,
      company_id: company_id
    }
  end

  defp past_date(type) do
    case type do
      :dob ->
        16..99
        |> FakerDate.date_of_birth()
        |> Date.to_string()

      :marr_anni ->
        ~D[1980-01-01]
        |> FakerDate.between(Date.utc_today())
        |> Date.to_string()

      :recent ->
        100
        |> FakerDate.backward()
        |> Date.to_string()
    end
  end

  # SALES ORDER SEED

  def create_sales_order(company_id, user_id, contact_id, products) do
    create_sales_order(%{
      company_id: company_id,
      user_id: user_id,
      contact_id: contact_id,
      products: products
    })
  end

  def add_category(company_id, user_id) do
    params = %{
      "company_id" => company_id,
      "user_id" => user_id,
      "title" => "#{Commerce.department()}"
    }

    Store.add_category(params)
  end

  def create_notification(company_id, actor_id, action_type, element, element_id) do
    params = %{
      element: element,
      element_id: element_id,
      action_type: action_type,
      company_id: company_id,
      actor_id: actor_id,
      notification_items: gen_notification_items()
    }

    Notifications.add_notification(params)
  end

  def add_tag(company_id, name) do
    %{
      company_id: company_id,
      name: name
    }
    |> Store.add_tag()
  end

  defp gen_notification_items do
    Enum.map(1..3, fn _index ->
      %{
        changed_to: "",
        current: "",
        item_type: "product",
        item_id: Enum.random(Repo.all(Product)).id
      }
    end)
  end

  defp create_sales_order(params) do
    params = %{
      date: past_date(:recent),
      payment_method: Enum.random(@payment_method),
      user_id: params.user_id,
      company_id: params.company_id,
      contact_id: params.contact_id,
      items: order_items(params.products),
      status: Enum.random(@seed_order_status)
    }

    SalesReg.Order.add_sale(params)
  end

  def create_invoice(order) do
    params = %{
      due_date: order.date,
      user_id: order.user_id,
      company_id: order.company_id,
      sale_id: order.id
    }

    SalesReg.Order.add_invoice(params)
  end

  def add_template do
    params = %{
      "title" => "Default Templates",
      "slug" => "yc1-template",
      "featured_image" => Avatar.image_url()
    }

    Theme.add_template(params)
  end

  def add_company_template(company_id, user_id, template_id) do
    params = %{
      "status" => "active",
      "company_id" => "#{company_id}",
      "user_id" => "#{user_id}",
      "template_id" => "#{template_id}"
    }

    Theme.add_company_template(params)
  end

  defp order_items(products) do
    Enum.map(products, fn product ->
      unit_price = Map.get(product, :price)

      %{
        "quantity" => "3",
        "unit_price" => unit_price,
        "product_id" => product.id
      }
    end)
  end

  defp order_total_cost(order_items) do
    amounts =
      order_items
      |> Enum.map(fn item ->
        unit_price = item["unit_price"] |> Decimal.new() |> Decimal.to_float()
        quantity = item["quantity"] |> Decimal.new() |> Decimal.to_float()
        unit_price * quantity
      end)

    "#{Enum.sum(amounts)}"
  end

  # create product
  @valid_product_params %{
    name: "Random Product name here",
    sku: "#{Enum.random(30..100)}",
    minimum_sku: "#{Enum.random(1..50)}",
    price: "#{Enum.random(1..50000)}",
    featured_image:
      "http://shfcs.org/en/wp-content/uploads/2015/11/MedRes_Product-presentation-2.jpg"
  }

  def add_product_without_variant(params, company_id, user_id),
    do: add_product_without_variant(params, company_id, user_id, [])

  def add_product_without_variant(params, company_id, user_id, categories) do
    params
    |> product_params(company_id, user_id, prod_grp.id, categories)
    |> Map.put(:title, prod_grp.title)
    |> Map.put(:tags, [])
    |> Store.add_product()
  end

  def add_product_with_variant(company, user) do
    product =
      company
      |> valid_product_params(user)
      |> Map.put(:tags, [])
      |> Map.put(:categories, [])

    params = %{
      product: product,
      company_id: company.id
    }

    Store.create_product(params)
  end

  defp valid_product_params(company, user) do
    @valid_product_params
    |> Map.put(:company_id, company.id)
    |> Map.put(:user_id, user.id)
  end

  defp product_params(
         [price, sku, min_sku, feat_img, name],
         company_id,
         user_id,
         prod_grp_id,
         categories
       ) do
    %{
      price: price,
      sku: sku,
      company_id: company_id,
      user_id: user_id,
      minimum_sku: min_sku,
      featured_image: feat_img,
      name: name,
      categories: categories,
      images: Enum.map(1..8, fn _index -> Avatar.image_url() end)
    }
  end
end

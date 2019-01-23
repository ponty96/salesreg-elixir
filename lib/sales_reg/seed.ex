defmodule SalesReg.Seed do
  use SalesRegWeb, :context

  alias Faker.{Phone.EnGb, Internet, Commerce, Avatar, Industry, Name, Address}
  alias Faker.Company.En, as: CompanyEn
  alias Faker.Name.En, as: NameEn
  alias Faker.Commerce.En, as: CommerceEn
  alias Faker.Date, as: FakerDate

  @location_types ["office", "home"]
  @phone_types ["home", "mobile", "work"]
  @currency ["Dollars", "Naira", "Euro", "Pounds"]
  @marital_status ["Single", "Married", "Widowed"]
  @banks ["076", "011", "063", "058"]
  @likes ["honesty", "integrity", "principled"]
  @dislikes ["lies", "pride", "laziness"]
  @payment_method ["cash", "card"]
  @seed_order_status ["pending", "processed", "delivering"]
  @gender ["MALE", "FEMALE"]
  @company_template_status ["active", "inactive"]

  def create_user() do
    user_params = %{
      "date_of_birth" => "15-08-1991",
      "email" => "samson.oluwole@gmail.com",
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
      contact_email: "official.sandbox@gmail.com",
      title: "Sandbox PLC",
      head_office: gen_location_params(),
      currency: "Naira",
      description: "Sandbox is basically into sales
       of Mobiles devices and related assessories of specific brands which
       include Samsung, Apple, Sony, Tecno, Infinix and Nokia. It also provides
       numerous services",
      logo:
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTTulsnrbHjdztPnDwdWzruyJ-p1gi7Mwf43hT7cC1oiwl1hU_h",
      slug: "Sandbox"
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

  def create_receipt(invoice_id, user_id, company_id) do
    current_date = Date.utc_today() |> Date.to_string()

    gen_receipt_details(invoice_id, user_id, company_id)
    |> Map.put_new(:time_paid, current_date)
    |> Order.add_receipt()
  end

  defp total_expense_cost(expense_items) do
    Enum.sum(Enum.map(expense_items, fn expense_item -> expense_item["amount"] end))
  end

  defp expenses_items() do
    Enum.map(1..5, fn _index ->
      %{
        "item_name" => CommerceEn.product_name_product(),
        "amount" => Enum.random([10_000.00, 50_000.00, 150_000.00])
      }
    end)
  end

  defp gen_location_params() do
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

  defp gen_phone_params() do
    %{
      "number" => "#{EnGb.mobile_number()}",
      "type" => Enum.random(@phone_types)
    }
  end

  def gen_bank_details() do
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
        FakerDate.date_of_birth(16..99)
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

  def create_sales_order(company_id, user_id, contact_id, items) do
    create_sales_order(
      %{
        company_id: company_id, 
        user_id: user_id, 
        contact_id: contact_id,
        items: items
      }
    )
  end

  def add_category(company_id, user_id) do
    params = %{
      "company_id" => company_id,
      "user_id" => user_id,
      "title" => "#{Commerce.department()}"
    }

    Store.add_category(params)
  end

  def add_tag(company_id, name) do
    %{
      company_id: company_id,
      name: name
    }
    |> Store.add_tag()
  end

  defp create_sales_order(params) do
    params = %{
      date: past_date(:recent),
      payment_method: Enum.random(@payment_method),
      user_id: params.user_id,
      company_id: params.company_id,
      contact_id: params.contact_id,
      items: params.items,
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

  def add_template() do
    params = %{
      "title" => "General Templates",
      "slug" => "template",
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

  defp order_items(items, type) do
    Enum.map(items, fn item ->
      unit_price = Map.get(item, :price)

      %{
        "quantity" => "3",
        "unit_price" => unit_price,
        "#{type}_id" => item.id
      }
    end)
  end

  defp order_total_cost(order_items) do
    amounts =
      Enum.map(order_items, fn item ->
        unit_price = Decimal.new(item["unit_price"]) |> Decimal.to_float()
        quantity = Decimal.new(item["quantity"]) |> Decimal.to_float()
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

  def add_product_without_variant(params, company_id, user_id) do
    {:ok, prod_grp} = insert_prod_grp(company_id)

    params
    |> product_params(company_id, user_id, prod_grp.id)
    |> Map.put(:option_values, [])
    |> Map.put(:tags, [])
    |> Map.put(:categories, [])
    |> Store.add_product()
  end

  def add_product_with_variant(company, user) do
    option_values = valid_option_values(company.id)

    product =
      company
      |> valid_product_params(user)
      |> Map.put(:option_values, option_values)
      |> Map.put(:tags, [])
      |> Map.put(:categories, [])

    params = %{
      product_group_title: CommerceEn.product_name(),
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

  defp valid_option_values(company_id) do
    options =
      company_id
      |> Store.list_company_options()
      |> elem(1)
      |> Enum.take(3)
      |> Enum.map(fn option ->
        %{
          option_id: option.id,
          name: CommerceEn.color(),
          company_id: company_id
        }
      end)

    options
  end

  defp insert_prod_grp(company_id) do
    params = %{
      "title" => "Mobile Devices and Assessories",
      "option_ids" => [],
      "company_id" => company_id
    }

    %ProductGroup{}
    |> ProductGroup.changeset(params)
    |> Repo.insert()
  end

  defp product_params([price, sku, min_sku, feat_img, name], company_id, user_id, prod_grp_id) do
    %{
      price: price,
      sku: sku,
      company_id: company_id,
      user_id: user_id,
      minimum_sku: min_sku,
      featured_image: feat_img,
      name: name,
      product_group_id: prod_grp_id
    }
  end
end

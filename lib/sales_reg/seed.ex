defmodule SalesReg.Seed do
  use SalesRegWeb, :context

  alias Faker.{Phone.EnGb, Internet, Commerce, Avatar, Industry, Name, Address}
  alias Faker.Company.En, as: CompanyEn
  alias Faker.Name.En, as: NameEn
  alias Faker.Commerce.En, as: CommerceEn
  alias Faker.Date, as: FakerDate

  @company_categories ["product", "service", "product_service"]
  @location_types ["office", "home"]
  @phone_types ["home", "mobile", "work"]
  @currency ["Dollars", "Naira", "Euro", "Pounds"]
  @marital_status ["Single", "Married", "Widowed"]
  @banks ["GTB", "FBN", "Sterling Bank", "Zenith Bank"]
  @likes ["honesty", "integrity", "principled"]
  @dislikes ["lies", "pride", "laziness"]

  def create_user() do
    user_params = %{
      "date_of_birth" => past_date(:dob),
      "email" => "someemail@gmail.com",
      "first_name" => "Opeyemi",
      "gender" => "male",
      "last_name" => "Badmos",
      "password" => "asdfasdf",
      "password_confirmation" => "asdfasdf"
    }

    Accounts.create_user(user_params)
  end

  def create_company(user_id) do
    company_params = %{
      about: "Building software products",
      contact_email: "someemail@gmail.com",
      title: "Stacknbit Private Limited Company",
      category: Enum.random(@company_categories),
      head_office: gen_location_params(),
      currency: "Naira(₦)",
      description: CompanyEn.bs(),
      logo: Avatar.image_url()
    }

    Business.create_company(user_id, company_params)
  end

  def add_product(user_id, company_id) do
    product_params = %{
      "description" => "Our product is #{CommerceEn.product_name()}",
      "featured_image" => Avatar.image_url(),
      "name" => CommerceEn.product_name(),
      "cost_price" => "#{Enum.random(3000..100_000)}",
      "minimum_stock_quantity" => "#{Enum.random(5..100)}",
      "selling_price" => "#{Commerce.price()}",
      "stock_quantity" => "#{Enum.random([3, 6, 12, 24])}",
      "user_id" => "#{user_id}",
      "company_id" => "#{company_id}"
    }

    Store.add_product(product_params)
  end

  def add_service(user_id, company_id) do
    service_params = %{
      "description" => "Our service is #{CompanyEn.bs()}",
      "name" => "#{CompanyEn.bs()} Service",
      "price" => "#{Enum.random([10_000, 50_000, 150_000])}",
      "user_id" => "#{user_id}",
      "company_id" => "#{company_id}"
    }

    Store.add_service(service_params)
  end

  def add_contact(user_id, company_id, type) do
    contact_params = %{
      "image" => Avatar.image_url(),
      "contact_name" => Name.En.name(),
      "phone" => gen_phone_params(),
      "email" => Internet.free_email(),
      "address" => gen_location_params(),
      "user_id" => "#{user_id}",
      "company_id" => "#{company_id}",
      "currency" => "#{Enum.random(@currency)}",
      "birthday" => past_date(:dob),
      "marital_status" => "#{Enum.random(@marital_status)}",
      "marriage_anniversary" => past_date(:marr_anni),
      "likes" => [
        Enum.random(@likes)
      ],

      "dislikes" => [
        Enum.random(@dislikes)
      ],
      "bank" => gen_bank_details(),
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

  defp total_expense_cost(expense_items) do
    Enum.sum(
      Enum.map(expense_items, fn expense_item -> expense_item["amount"] end)
    )
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
      "lat" => "#{Address.latitude}",
      "long" => "#{Address.longitude}",
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
      "account_name" => NameEn.name(),
      "account_number" => Enum.random(0152637490..0163759275),
      "bank_name" => "#{Enum.random(@banks)}"
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
        |> Date.to_string
    end

  end
end

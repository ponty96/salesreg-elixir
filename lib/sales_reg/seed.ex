defmodule SalesReg.Seed do
  use SalesRegWeb, :context

  alias Faker.{Phone.EnGb, Avatar}

  @company_categories ["product", "service", "product_service"]
  @location_types ["office", "home"]
  @phone_types ["home", "mobile", "work"]
  @currency ["Dollars", "Naira", "Euro", "Pounds"]
  @marital_status ["Single", "Married", "Widowed"]
  @banks ["GTB", "FBN", "Sterling Bank", "Zenith Bank"]

  def create_user() do
    user_params = %{
      "date_of_birth" => "#{dob()}",
      "email" => "someemail@gmail.com",
      "first_name" => "Opeyemi",
      "gender" => "male",
      "last_name" => "Badmos",
      "password" => "asdfasdf",
      "password_confirmation" => "asdfasdf",
      "phone" => gen_phone_params()
    }

    Accounts.create_user(user_params)
  end

  def create_company(user_id) do
    company_params = %{
      about: "Building software products",
      contact_email: "someemail@gmail.com",
      title: "Stacknbit Private Limited Company",
      category: Enum.random(@company_categories),
      head_office: gen_location_params(0),
      currency: "Naira(₦)"
    }

    Business.create_company(user_id, company_params)
  end

  def add_company_employee(branch_id, user_id, company_id) do
    employee_params = %{
      person_id: "#{user_id}",
      branch_id: "#{branch_id}"
    }

    Business.add_company_employee(company_id, employee_params)
  end

  def add_product(index, user_id, company_id) do
    product_params = %{
      "description" => "Our product is #{index}",
      "featured_image" => Avatar.image_url(),
      "name" => "product name #{index}",
      "cost_price" => "#{Enum.random(3000..100_000)}",
      "minimum_stock_quantity" => "#{Enum.random(5..100)}",
      "selling_price" => "#{index}0",
      "stock_quantity" => "#{Enum.random([3, 6, 12, 24])}",
      "user_id" => "#{user_id}",
      "company_id" => "#{company_id}"
    }

    Store.add_product(product_params)
  end

  def add_service(index, user_id, company_id) do
    service_params = %{
      "description" => "The description of the service is description #{index}",
      "name" => "The name of the service is name #{index}",
      "price" => "#{Enum.random([10_000, 50_000, 150_000])}#{index}",
      "user_id" => "#{user_id}",
      "company_id" => "#{company_id}"
    }

    Store.add_service(service_params)
  end

  def add_customer(index, user_id, company_id) do
    customer_params = %{
      "image" => Avatar.image_url(),
      "customer_name" => "customer name #{index}",
      "phone" => gen_phone_params(1),
      "email" => "someemail#{index}@gmail.com",
      "address" => gen_location_params(index),
      "user_id" => "#{user_id}",
      "company_id" => "#{company_id}",
      "currency" => "#{Enum.random(@currency)}#{index}",
      "birthday" => "#{dob()}",
      "marital_status" => "#{Enum.random(@marital_status)}",
      "marriage_anniversary" => "marriage anniversary #{index}",
      "likes" => [
        "honesty #{index}",
        "integrity #{index}",
        "principle #{index}"
      ],
      "dislikes" => [
        "lies #{index}",
        "pride #{index}"
      ],
      "bank" => gen_bank_details(index)
    }

    Business.add_customer(customer_params)
  end

  def add_vendor(index, user_id, company_id) do
    vendor_params = %{
      "email" => "email#{index}@gmail.com",
      "fax" => "+234",
      "city" => "city#{index}",
      "state" => "state#{index}",
      "country" => "country#{index}",
      "currency" => "#{Enum.random(@currency)}#{index}",
      "locations" =>
        Enum.map(1..5, fn _index ->
          gen_location_params(index)
        end),
      "user_id" => "#{user_id}",
      "company_id" => "#{company_id}"
    }

    Business.add_vendor(vendor_params)
  end

  defp gen_location_params(index) do
    increament_index = index + 1

    %{
      "city" => "city #{index}",
      "country" => "country #{index}",
      "state" => "state #{index}",
      "lat" => "#{index}",
      "long" => "#{index}",
      "street1" => "#{index}",
      "street2" => "#{increament_index}",
      "type" => Enum.random(@location_types)
    }
  end

  defp gen_phone_params(index \\ "") do
    %{
      "number" => "#{EnGb.mobile_number()}#{index}",
      "type" => Enum.random(@phone_types)
    }
  end

  defp dob() do
    "#{Enum.random(1..31)}-#{Enum.random(1..12)}-#{Enum.random(1960..2000)}"
  end

  def gen_bank_details(index) do
    %{
      "account_name" => "customer name #{index}",
      "account_number" => "000000000#{index}",
      "bank_name" => "#{Enum.random(@banks)}#{index}"
    }
  end
end

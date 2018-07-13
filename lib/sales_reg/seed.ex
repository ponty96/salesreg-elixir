defmodule SalesReg.Seed do
  use SalesRegWeb, :context

  alias Faker.{
    Internet,
    Commerce,
    Avatar,
    Address,
    Phone.EnGb
  }

  alias Faker.Company.En, as: CompanyEn
  alias Faker.Name.En, as: NameEn
  alias Faker.Commerce.En, as: CommerceEn

  @company_categories ["product", "service", "product_service"]
  @location_types ["office", "home"]
  @phone_types ["home", "mobile", "work"]
  @currency ["Dollars", "Naira", "Euro", "Pounds"]

  def create_user() do
    user_params = %{
      "date_of_birth" => "#{dob()}",
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
      currency: "naira"
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
      "description" => "Our product is product#{index}",
      "featured_image" => "featured image #{index}",
      "name" => "name #{index}",
      "pack_quantity" => "#{index}",
      "price_per_pack" => "#{index}0",
      "selling_price" => "#{index}",
      "unit_quantity" => "#{index}",
      "user_id" => "#{user_id}",
      "company_id" => "#{company_id}"
    }

    Store.add_product(product_params)
  end

  def add_service(index, user_id, company_id) do
    service_params = %{
      "description" => "The description of the service is service #{index}",
      "name" => "The name of the service is service #{index}",
      "price" => "#{Enum.random([10_000, 50_000, 150_000])}#{index}",
      "user_id" => "#{user_id}",
      "company_id" => "#{company_id}"
    }

    Store.add_service(service_params)
  end

  def add_customer(index, user_id, company_id) do
    customer_params = %{
      "image" => "image #{index}",
      "customer_name" => "customer name #{index}",
      "phones" =>
        Enum.map(1..2, fn _index ->
          gen_phone_params(index)
        end),
      "residential_add" => gen_location_params(index),
      "office_add" => gen_location_params(index),
      "email" => "someemail#{index}@gmail.com",
      "fax" => "+234",
      "city" => "city #{index}",
      "state" => "state #{index}",
      "country" => "country #{index}",
      "user_id" => "#{user_id}",
      "company_id" => "#{company_id}"
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
    %{
      "city" => "city #{index}",
      "country" => "country #{index}",
      "state" => "state #{index}",
      "lat" => "#{index}",
      "long" => "#{index}",
      "street1" => "#{index}",
      "street2" => "#{index + 1}",
      "type" => Enum.random(@location_types)
    }
  end

  defp gen_phone_params(index) do
    %{
      "number" => "#{EnGb.mobile_number()}#{index}",
      "type" => Enum.random(@phone_types)
    }
  end

  defp dob() do
    "#{Enum.random(1..31)}-#{Enum.random(1..12)}-#{Enum.random(1960..2000)}"
  end
end

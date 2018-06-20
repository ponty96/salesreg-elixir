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
      "email" => "opeyemi.badmos@gmail.com",
      "first_name" => "Opeyemi",
      "gender" => "male",
      "last_name" => "Badmos",
      "password" => "asdf",
      "password_confirmation" => "asdf"
    }

    Accounts.create_user(user_params)
  end

  def create_company(user_id) do
    company_params = %{
      about: "Building software products",
      contact_email: "opeyemi.badmos@gmail.com",
      title: "Stacknbit Private Limited Company",
      category: Enum.random(@company_categories)
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

  def add_product(user_id, company_id) do
    product_params = %{
      "description" => "Our product is #{CommerceEn.product_name()}",
      "featured_image" => "#{Avatar.image_url()}",
      "name" => "#{CommerceEn.product_name()}",
      "pack_quantity" => "#{Enum.random(5..100)}",
      "price_per_pack" => "##{Enum.random(3000..100_000)}",
      "selling_price" => "##{Commerce.price()}",
      "unit_quantity" => "#{Enum.random([3, 6, 12, 24])}",
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

  def add_customer(index, user_id, company_id) do
    customer_params = %{
      "image" => "#{Avatar.image_url()}",
      "customer_name" => "#{NameEn.name()}",
      "phones" =>
        Enum.map(1..2, fn _index ->
          gen_phone_params(index)
        end),
      "residential_add" => gen_location_params(),
      "office_add" => gen_location_params(),
      "email" => "#{Internet.free_email()}",
      "fax" => "+234",
      "city" => "#{Address.city()}",
      "state" => "#{Address.state()}",
      "country" => "#{Address.country()}",
      "user_id" => "#{user_id}",
      "company_id" => "#{company_id}"
    }

    Business.add_customer(customer_params)
  end

  def add_vendor(user_id, company_id) do
    vendor_params = %{
      "email" => "#{Internet.free_email()}",
      "fax" => "+234",
      "city" => "#{Address.city()}",
      "state" => "#{Address.state()}",
      "country" => "#{Address.country()}",
      "currency" => "#{Enum.random(@currency)}",
      "locations" =>
        Enum.map(1..5, fn _index ->
          gen_location_params()
        end),
      "user_id" => "#{user_id}",
      "company_id" => "#{company_id}"
    }

    Business.add_vendor(vendor_params)
  end

  defp gen_location_params() do
    %{
      "city" => "#{Address.city()}",
      "country" => "#{Address.country()}",
      "state" => "#{Address.state()}",
      "lat" => "#{Address.latitude()}",
      "long" => "#{Address.longitude()}",
      "street1" => "#{Address.street_address()}",
      "street2" => "#{Address.street_address()}",
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

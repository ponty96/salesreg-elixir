# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     SalesReg.Repo.insert!(%SalesReg.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
use SalesRegWeb, :context

tags = [
  "#love",
  "#instagood",
  "#tgif",
  "#tbt",
  "#picoftheday",
  "#instalike",
  "#igers",
  "#follow4follow",
  "#instamood",
  "#family",
  "#nofilter"
]

{:ok, user} = Seed.create_user()
{:ok, company} = Seed.create_company(user.id)
{:ok, template} = Seed.add_template()
{:ok, company_template} = Seed.add_company_template(company.id, user.id, template.id)


Enum.map(1..5, fn _index ->
  Seed.add_product_without_variant(company, user)
end)

Enum.map(1..5, fn _index ->
  Seed.add_product_with_variant(company, user)
end)

categories =
  Enum.map(1..25, fn _index ->
    {:ok, category} = Seed.add_category(company.id, user.id)
    category.id
  end)

services =
  Enum.map(1..20, fn _index ->
    {:ok, service} = Seed.add_service(user.id, company.id, Enum.take_random(categories, 5), tags)
    service
  end)

customers =
  Enum.map(1..25, fn _index ->
    {:ok, customer} = Seed.add_contact(user.id, company.id, "customer")
    customer
  end)

vendors =
  Enum.map(1..25, fn _index ->
    {:ok, vendor} = Seed.add_contact(user.id, company.id, "vendor")
    vendor
  end)

Enum.map(1..20, fn _index ->
  Seed.add_expense(user.id, company.id)
end)

templates = 
  Enum.map(1..5, fn _index ->
    {:ok, templates} = Seed.add_template()
    templates
  end)

Seed.add_company_template(company.id, user.id, template.id)

branch =
  Repo.all(Branch)
  |> Enum.random()

random_vendors = Enum.take_random(vendors, 8)
random_customers = Enum.take_random(customers, 8)

# Enum.map(random_customers, fn customer ->
#   Seed.create_sales_order(company.id, user.id, customer.id, %{items: products, type: "product"})
# end)

Enum.map(random_customers, fn customer ->
  Seed.create_sales_order(company.id, user.id, customer.id, %{items: services, type: "service"})
end)

# Enum.map(random_customers, fn customer ->
#   Seed.create_sales_order(company.id, user.id, customer.id, products, services)
# end)

Enum.map(1..10, fn _index ->
  Seed.create_bank(company.id)
end)

# sale_order =
#   SalesReg.Order.processed_sale_orders()
#   |> Enum.random()

# {:ok, invoice} = Seed.create_invoice(sale_order)

# Seed.create_receipt(invoice.id, user.id, company.id)




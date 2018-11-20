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

names = [
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

categories =
  Enum.map(1..25, fn _index ->
    {:ok, category} = Seed.add_category(company.id, user.id)
    category.id
  end)

tags =
  Enum.map(names, fn name ->
    {:ok, tag} = Seed.add_tag(company.id, name)
    tag.name
  end)

products =
  Enum.map(1..20, fn _index ->
    {:ok, product} = Seed.add_product(user.id, company.id, Enum.take_random(categories, 6), tags)
    product
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

branch =
  Repo.all(Branch)
  |> Enum.random()

random_vendors = Enum.take_random(vendors, 8)
random_customers = Enum.take_random(customers, 8)

Enum.map(random_vendors, fn vendor ->
  Seed.create_purchase_order(company.id, user.id, vendor.id, products)
end)

Enum.map(random_customers, fn customer ->
  Seed.create_sales_order(company.id, user.id, customer.id, %{items: products, type: "product"})
end)

Enum.map(random_customers, fn customer ->
  Seed.create_sales_order(company.id, user.id, customer.id, %{items: services, type: "service"})
end)

Enum.map(random_customers, fn customer ->
  Seed.create_sales_order(company.id, user.id, customer.id, products, services)
end)

Enum.map(1..10, fn _index ->
  Seed.create_bank(company.id)
end)

sale_order = 
  Seed.processed_sale_orders() 
  |> Enum.random()

Seed.create_invoice(sale_order)
  


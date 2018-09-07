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

{:ok, user} = Seed.create_user()
{:ok, company} = Seed.create_company(user.id)

Enum.map(1..20, fn index ->
  Seed.add_product(index, user.id, company.id)
end)

Enum.map(1..20, fn index ->
  Seed.add_service(index, user.id, company.id)
end)

Enum.map(1..50, fn index ->
  Seed.add_contact(index, user.id, company.id, Enum.random(["customer", "vendor"]))
end)

Enum.map(1..20, fn index ->
  Seed.add_expense(index, user.id, company.id)
end)
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

Enum.map(1..20, fn(_index) -> 
	Seed.add_product(user.id, company.id)
end)

Enum.map(1..20, fn(_index) ->
	Seed.add_service(user.id, company.id)
end)

Enum.map(1..30, fn(index) ->
	Seed.add_contact(index, user.id, company.id)
end)

branch = Repo.all(Branch)
		 |> Enum.random()

Enum.map(1..30, fn(_index) ->
	Seed.add_company_employee(branch.id, user.id, company.id)
end)

Enum.map(1..30, fn(_index) ->
	Seed.add_vendor(user.id, company.id)
end)







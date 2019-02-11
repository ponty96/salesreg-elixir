use SalesRegWeb, :context

Repo.all(Company)
|> Enum.map(&Business.insert_company_email_temps(&1.id))

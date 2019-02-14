alias SalesReg.{Repo, Theme, Theme.CompanyEmailTemplate}

email_templates = Repo.all(CompanyEmailTemplate)

Enum.map(email_templates, fn temp ->
  type = temp.type

  {:ok, binary} =
    ("./lib/sales_reg_web/templates/mailer/#{type}" <> ".html.eex")
    |> Path.expand()
    |> File.read()

  temp
  |> Theme.update_company_email_template(%{body: binary})
end)

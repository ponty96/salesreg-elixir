defmodule SalesRegWeb.GraphQL.Resolvers.CompanyResolver do
  use SalesRegWeb, :context

  def register_company(%{user: user_id, company: company_params}, _resolution) do
    with {:ok, company} <- Business.create_company(user_id, company_params),
         {:ok, _} <- Business.send_registration_email(user_id, company) do
      {:ok, company}
    else
      {:error, changeset} -> {:error, changeset}
    end
  end

  def update_company(%{id: company_id, company: company_params}, _res) do
    {_status, result} = Business.update_company_details(company_id, company_params)

    case result do
      %Company{} -> {:ok, result}
      %Ecto.Changeset{} -> {:error, result}
    end
  end
end

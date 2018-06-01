defmodule SalesRegWeb.GraphQL.Resolvers.CompanyResolver do
  use SalesRegWeb, :context

  def register_company(%{user: user_params, company: company_params}, _resolution) do
    with {:ok, user} <- Accounts.create_user(user_params),
         {:ok, company} <- Business.create_company(user.id, company_params),
         {:ok, _} <- Business.send_registration_email(user, company) do
      {:ok, company}
    else
      {:error, changeset} -> {:error, changeset}
    end
  end
end

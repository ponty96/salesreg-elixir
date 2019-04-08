defmodule SalesReg.Policies.Policy do
  @moduledoc """
  Policy Module
  """
  alias SalesReg.Accounts
  alias SalesReg.Accounts.User
  alias SalesReg.Business
  alias SalesReg.Business.Company
  require Logger

  def can?(action_type, user_id, company_id) do
    case fetch_details(user_id, company_id) do
      {:ok, %{user: user, company: company}} -> can_do?(action_type, user, company)
      {:error, error} -> {:error, error}
    end
  end

  defp can_do?(:admin_task, user, company) do
    case company.owner_id == user.id do
      true ->
        Logger.info(
          "User #{user.first_name}, has permission to perform admin_task on company #{
            company.title
          }"
        )

        {:ok, "done"}

      false ->
        Logger.error(
          "User #{user.first_name}, does not have permission to perform admin_task on company #{
            company.title
          }"
        )

        {:error, [%{key: "email", message: "Something went wrong. Try again!"}]}
    end
  end

  defp fetch_details(user_id, company_id) do
    with %User{} = user <- Accounts.get_user(user_id),
         %Company{} = company <- Business.get_company(company_id) do
      {:ok, %{user: user, company: company}}
    else
      _ -> {:error, [%{key: "email", message: "Something went wrong. Try again!"}]}
    end
  end
end

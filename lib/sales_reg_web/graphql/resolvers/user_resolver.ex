defmodule SalesRegWeb.GraphQL.Resolvers.UserResolver do
  alias SalesReg.Accounts
  alias SalesRegWeb.GraphQL.Helpers.MutationResponse
  alias SalesReg.Accounts.User
  alias SalesRegWeb.Authentication

  def get_user(%{id: id}, resolution) do
    case resolution do
      %{context: %{current_user: _}} ->
        user = Accounts.get_user(id)

        case user do
          %User{} ->
            {:ok, user}

          _ ->
            {:error, "Something went wrong. Try again!"}
        end

      _ ->
        {:ok, resolution}
    end
  end

  def login_user(params, _resolution) do
    Authentication.login(params)
  end

  def verify_tokens(params, _resolution) do
    Authentication.verify_tokens(params)
  end

  def refresh_token(params, _resolution) do
    Authentication.refresh_token(params)
  end
end

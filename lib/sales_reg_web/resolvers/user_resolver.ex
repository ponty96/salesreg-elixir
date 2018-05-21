defmodule SalesRegWeb.Resolvers.UserResolver do
  alias SalesReg.Accounts
  alias SalesRegWeb.Helpers.MutationResponse
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

  def register_user(%{user: params}, _resolution) do
    Authentication.register(params)
    |> MutationResponse.build_response()
  end

  def login_user(params, _resolution) do
    Authentication.login(params)
    |> MutationResponse.build_response()
  end
end

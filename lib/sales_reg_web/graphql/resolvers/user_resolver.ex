defmodule SalesRegWeb.GraphQL.Resolvers.UserResolver do
  use SalesRegWeb, :context
  alias SalesRegWeb.TokenImpl

  def register_user(%{user: user_params}, _resolution) do
    Accounts.register_user(user_params)
  end

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

  def logout(params, _resolution) do
    Authentication.logout(params)
  end

  def update_user(%{user: params}, %{context: %{current_user: user}}) do
    Accounts.update_user(user, params)
  end
end

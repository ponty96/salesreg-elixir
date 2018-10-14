defmodule SalesRegWeb.GraphQL.Resolvers.UserResolver do
  use SalesRegWeb, :context
  alias SalesRegWeb.TokenImpl
  alias SalesReg.ImageUpload

  def register_user(%{user: user_params}, _resolution) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        {:ok, token, _} = TokenImpl.encode_and_sign(user, %{}, token_type: "access")

        {:ok, {old_token, _old_claim}, {new_token, _new_claim}} =
          TokenImpl.exchange(token, "access", "refresh", ttl: {30, :days})

        {:ok, %{user: user, access_token: old_token, refresh_token: new_token}}

      {:error, changeset} ->
        {:error, changeset}
    end
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
    case params do
      %{profile_picture: binary} -> 
        build_params = 
        ImageUpload.upload_image(binary)
        |> build_params(params)
    
        Accounts.update_user(user, build_params)
      
      _ ->
        Accounts.update_user(user, params)
    end
  end

  defp build_params(term, params) when is_tuple(term) do
    {:ok, filename} = term
    %{
      params | 
      profile_picture: filename
    }
    |> Map.put_new(:upload_successful?, true)
  end

  defp build_params(term, params) when is_atom(term) do
    params
    |> Map.put_new(:upload_successful?, false)
  end
end

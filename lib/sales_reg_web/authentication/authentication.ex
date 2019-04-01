defmodule SalesRegWeb.Authentication do
  @moduledoc """
     General Authentication service
  """
  use SalesRegWeb, :context

  def login(user_params) do
    with %User{} = user <- Accounts.get_user_by_email(user_params.email),
         true <- check_password(user, user_params.password) do
      # rel_date is the naive date time of April 1st 2019
      {:ok, rel_date} = NaiveDateTime.new(2019, 4, 1, 0, 0, 0)

      if NaiveDateTime.diff(rel_date, user.inserted_at) > 0 do
        sign_in(user)
      else
        handle_user_company_response(user)
      end
    else
      nil ->
        {:error, [%{key: "email", message: "Something went wrong. Try again!"}]}

      false ->
        {:error, [%{key: "email", message: "Email | Password Incorrect"}]}
    end
  end

  def put_user_in_session(conn, user) do
    conn
    |> Conn.assign(:current_user, user)
    |> Conn.put_session(:user_id, user.id)
    |> Conn.configure_session(renew: true)
  end

  # This function returns a new access token and refresh token if the access token has 
  # expired but the refresh token has not expired, else if both has expired, the user
  # is logged out (revoked), else, the original access token and refresh token is 
  # sent back
  def verify_tokens(%{access_token: access_token, refresh_token: refresh_token}) do
    case tokens_exist?(access_token, refresh_token) do
      {access_claims, refresh_claims} ->
        current_time = Guardian.timestamp()
        user = load_resource(access_claims)

        cond do
          current_time > access_claims["exp"] and current_time > refresh_claims["exp"] ->
            TokenImpl.revoke(access_token)
            TokenImpl.revoke(refresh_token)
            {:ok, %{user: user, message: "Logged out"}}

          current_time >= access_claims["exp"] and current_time < refresh_claims["exp"] ->
            {:ok, token, _claim} = TokenImpl.encode_and_sign(user, %{}, token_type: "access")

            {:ok, {old_token, _old_claim}, {new_token, _new_claim}} =
              TokenImpl.exchange(token, "access", "refresh", ttl: {30, :days})

            {:ok, %{user: user, access_token: old_token, refresh_token: new_token}}

          current_time < access_claims["exp"] ->
            {:ok, %{user: user, access_token: access_token, refresh_token: refresh_token}}

          true ->
            {:ok, %{user: user, message: "You're logged out"}}
        end

      :not_found ->
        {:error, "Token does not exist"}
    end
  end

  # This function returns a new refresh token (the expiration date is extendend)
  # while keeping all the jwt claims intact if it has not expired, else the token
  # is deleted from the database - user is logged out. 
  def refresh_token(%{refresh_token: token}) do
    case decode_and_verify(token, "refresh") do
      {:ok, claims} ->
        user = load_resource(claims)
        current_time = Guardian.timestamp()

        if current_time < claims["exp"] do
          {:ok, {old_token, _old_claims}, {new_token, _new_claims}} =
            TokenImpl.refresh(token, ttl: {30, :days})

          TokenImpl.revoke(old_token)
          {:ok, %{user: user, refresh_token: new_token}}
        else
          TokenImpl.revoke(token)
          {:ok, %{user: user, message: "You're logged out"}}
        end

      _ ->
        {:error, "Token does not exist"}
    end
  end

  def logout(%{access_token: token}) do
    resource_from_token = TokenImpl.resource_from_token(token, %{"typ" => "access"})

    case resource_from_token do
      {:ok, resource, _claims} ->
        TokenImpl.revoke(token)
        {:ok, %{user: resource, message: "You're logged out"}}

      {:error, _any} ->
        {:error, "Invalid token"}
    end
  end

  def authenticate(%Ueberauth.Auth{provider: :identity} = auth) do
    Accounts.get_user_by_email(auth.uid)
    |> authorize(auth)
  end

  def sign_in(user) do
    {:ok, token, _} = TokenImpl.encode_and_sign(user, %{}, token_type: "access")

    {:ok, {old_token, _old_claim}, {new_token, _new_claim}} =
      TokenImpl.exchange(token, "access", "refresh", ttl: {30, :days})

    {:ok, %{user: user, access_token: old_token, refresh_token: new_token}}
  end

  defp handle_user_company_response(user) do
    case Accounts.get_user_company(user) do
      %Company{} ->
        if user.confirmed_email? == true do
          sign_in(user)
        else
          {:error, [%{key: "email", message: "Confirm your email to continue"}]}
        end

      nil ->
        sign_in(user)
    end
  end

  defp tokens_exist?(access_token, refresh_token) do
    case decode_and_verify(access_token, "access") do
      {:ok, access_claims} ->
        case decode_and_verify(refresh_token, "refresh") do
          {:ok, refresh_claims} -> {access_claims, refresh_claims}
          _ -> :not_found
        end

      _ ->
        :not_found
    end
  end

  defp decode_and_verify(token, type) do
    TokenImpl.decode_and_verify(token, %{"typ" => type})
  end

  defp load_resource(claims) do
    id = claims["sub"]
    Accounts.get_user(id)
  end

  defp check_password(user, password) do
    Comeonin.Bcrypt.checkpw(password, user.hashed_password)
  end

  defp authorize(nil, _auth) do
    {:error, "Invalid username or password"}
  end

  defp authorize(user, auth) do
    check_password(user, auth.credentials.other.password)
    |> resolve_authorization(user)
  end

  defp resolve_authorization(false, _user), do: {:error, "Invalid username or password"}
  defp resolve_authorization(true, user), do: {:ok, user}
end

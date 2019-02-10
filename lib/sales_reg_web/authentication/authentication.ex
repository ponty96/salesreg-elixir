defmodule SalesRegWeb.Authentication do
  @moduledoc """
     General Authentication service
  """
  use SalesRegWeb, :context

  def login(user_params) do
    user = Accounts.get_user_by_email(String.downcase(user_params.email))
    password = user_params.password

    case user do
      %User{} ->
        if check_password(user, password) == true do
          {:ok, token, _} = TokenImpl.encode_and_sign(user, %{}, token_type: "access")

          {:ok, {old_token, _old_claim}, {new_token, _new_claim}} =
            TokenImpl.exchange(token, "access", "refresh", ttl: {30, :days})

          {:ok, %{user: user, access_token: old_token, refresh_token: new_token}}
        else
          {:error, [%{key: "email", message: "Email | Password Incorrect"}]}
        end

      nil ->
        {:error, [%{key: "email", message: "Something went wrong. Try again!"}]}
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

  def reset_password(email) do
    with %User{} = user <- Accounts.get_user_by_email(email),
        {:ok, password_reset} <- Accounts.add_password_reset(%{user_id: user.id}),
        url <-  "https://www.#{System.get_env("BASE_DOMAIN")}/#{password_reset.id}",
        {params, text_body} <- Mailer.reset_pass_params(email, url), 
        %Bamboo.Email{} <- Email.send_email(params, text_body) do
      
      {:ok, "An email has been sent to you. Please check your email"}
    else
      nil -> {:error, "User does not exist"}
      {:error, _reason} = error -> error
    end
  end

  def reset_password(params, reset_id) do
    with password_reset <- Accounts.get_password_reset(reset_id),
        true <- password_reset_expired?(password_reset), 
        user <- get_pass_reset_user(password_reset),
        {:ok, _user} <- Accounts.update_user_password(user, params)
        do
      Accounts.delete_password_reset(password_reset)
      {:ok, "Your password has been changed successfully"}
    else
      nil -> {:error, "No prior request to change user password"}
      false -> {:error, "Reset Password Expired"}
      {:error, _reason} = error -> error
    end
  end

  def authenticate(%Ueberauth.Auth{provider: :identity} = auth) do
    Accounts.get_user_by_email(auth.uid)
    |> authorize(auth)
  end

  defp password_reset_expired?(password_reset) do
    date_initialized = password_reset.inserted_at
    date_expired = NaiveDateTime.add(date_initialized, 86400)
    
    if NaiveDateTime.diff(date_expired, NaiveDateTime.utc_now()) > 0 do
      true
    else
      false
    end
  end

  defp get_pass_reset_user(password_reset) do
    Repo.preload(password_reset, [:user]).user
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

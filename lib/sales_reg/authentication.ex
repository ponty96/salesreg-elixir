defmodule SalesReg.Authentication do
  @moduledoc """
     General Authentication service
  """

  alias SalesReg.Accounts
  alias SalesReg.Guardian

  def register(params) do
    {:ok, user} = Accounts.create_user(params)
    {:ok, jwt, _claims} = Guardian.encode_and_sign(user)

    {:ok, %{user: user, jwt: jwt}}
  end

  def login(params) do
    user = Accounts.get_user_by_email(String.downcase(params.email))
    password = params.password

    case check_password(user, password) do
      true ->
        {:ok, user}
        {:ok, jwt, _} = Guardian.encode_and_sign(user)

        {:ok, %{user: user, jwt: jwt}}

      false ->
        {:error, [%{key: "email", message: "Email | Password Incorrect"}]}

      :not_found ->
        {:error, [%{key: "email", message: "User has not registered"}]}
    end
  end

  defp check_password(user, password) do
    case user do
      nil -> :not_found
      _ -> Comeonin.Bcrypt.checkpw(password, user.hashed_password)
    end
  end
end

defmodule SalesRegWeb.Authentication do
  @moduledoc """
     General Authentication service
  """

  alias SalesReg.Accounts
  alias SalesRegWeb.Guardian
  alias SalesReg.Accounts.User

  def register(user_params) do
    {:ok, user} = Accounts.create_user(user_params)
    {:ok, jwt, _claims} = Guardian.encode_and_sign(user)

    {:ok, %{user: user, jwt: jwt}}
  end

  def login(user_params) do
    user = Accounts.get_user_by_email(String.downcase(user_params.email))
    password = user_params.password

    case user do
      %User{} ->
        if check_password(user, password) == true do
          {:ok, jwt, _} = Guardian.encode_and_sign(user)

          {:ok, %{user: user, jwt: jwt}}
        else
          {:error, [%{key: "email", message: "Email | Password Incorrect"}]}
        end

      nil ->
        {:error, [%{key: "email", message: "Something went wrong. Try again!"}]}
    end
  end

  defp check_password(user, password) do
    Comeonin.Bcrypt.checkpw(password, user.hashed_password)
  end
end

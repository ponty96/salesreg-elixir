defmodule SalesReg.Authentication do
  @moduledoc """
    General Authentication service
	"""

	alias SalesReg.Accounts
	alias SalesReg.Guardian
	
	def register(params) do
		{:ok, user} = Accounts.create_user(params)
		{:ok, jwt, _claims} = Guardian.encode_and_sign(user)
		
		{:ok, %{token: jwt}}
	end

	def login(params) do
		user = Accounts.get_user_by_email(String.downcase(params.email))
    case check_password(user, params.password) do
			true -> {:ok, user}
							{:ok, jwt, _} = Guardian.encode_and_sign(user)
							
							{:ok, %{token: jwt}}
      _ -> {:error, "Incorrect login details"}
    end
	end
	
 
  defp check_password(user, password) do
    case user do
      nil -> false
      _ -> Comeonin.Bcrypt.checkpw(password, user.password_hash)
    end
  end

 
end

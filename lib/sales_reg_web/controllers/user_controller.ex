defmodule SalesRegWeb.UserController do
	use SalesRegWeb, :controller
	use SalesRegWeb, :context
	
	plug Ueberauth
  
	def new(conn, _params) do
		changeset = Accounts.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
	end
	
	def create(conn, %{"user" => params}) do
		case Accounts.create_user(params) do
      {:ok, user} ->
        conn
        |> Authentication.put_user_in_session(user)        
        |> put_flash(:info, "Registration Successful!")
				|> redirect(to: company_path(conn, :new))

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
	end

	# def authenticate(%Ueberauth.Auth{provider: :identity} = auth) do
  #   Repo.get_by(User, email: auth.uid)
  # 	  |> authorize(auth)
  # end

  # defp authorize(nil,_auth) do
  #   {:error, "Invalid username or password"}
  # end

  # defp authorize(user, auth) do
  #   checkpw(auth.credentials.other.password, user.password_hash)
  #   |> resolve_authorization(user)
  # end

  # defp resolve_authorization(false, _user), do: {:error, "Invalid username or password"}
  # defp resolve_authorization(true, user), do: {:ok, user}
end
  
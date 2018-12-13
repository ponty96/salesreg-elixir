defmodule SalesRegWeb.UserController do
	use SalesRegWeb, :controller
	use SalesRegWeb, :context
	  
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
end
  
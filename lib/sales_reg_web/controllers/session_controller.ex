defmodule SalesRegWeb.SessionController do
  use SalesRegWeb, :controller
  use SalesRegWeb, :context

  plug Ueberauth
  alias Ueberauth.Strategy.Helpers

  def request(conn, _params) do
    render(conn, "new.html", callback_url: Helpers.callback_url(conn))
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case Authentication.authenticate(auth) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Successfully authenticated.")
        |> put_session(:current_user, user)
        |> configure_session(renew: true)
        |> redirect(to: "/")

      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: "/")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out!")
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end
end

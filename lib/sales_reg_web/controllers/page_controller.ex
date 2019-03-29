defmodule SalesRegWeb.PageController do
  use SalesRegWeb, :controller
  use SalesRegWeb, :context

  def confirm_email(conn, %{"email" => _email} = params) do
    Accounts.confirm_user_email(params)
    render(conn, "confirm-email.html")
  end
end

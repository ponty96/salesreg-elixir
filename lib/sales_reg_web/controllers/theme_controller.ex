defmodule SalesRegWeb.ThemeController do
  use SalesRegWeb, :controller

  def index(conn, _params) do
    # Do Something
    conn
    |> put_view(SalesRegWeb.Theme.Yc1View)
    |> render("index.html")
  end
end

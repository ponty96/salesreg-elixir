defmodule SalesRegWeb.ThemeController do
  use SalesRegWeb, :controller

  def index(conn, _params) do
    # Do Something
    conn
    |> put_layout({SalesRegWeb.Theme.Yc1View, "app.html"})
    |> put_view(SalesRegWeb.Theme.Yc1View)
    |> render("index.html")
  end
end

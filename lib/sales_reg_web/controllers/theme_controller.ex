defmodule SalesRegWeb.ThemeController do
  use SalesRegWeb, :controller

  def index(%{assigns: %{company_id: company_id}} = conn, _params) do
    conn
    |> render("index.html")
  end
end

defmodule SalesRegWeb.StoreController do
  use SalesRegWeb, :controller

  def index_products(%{assigns: %{company_id: company_id}} = conn, _params) do
    conn
    |> render("products.html")
  end

  def show_product(%{assigns: %{company_id: company_id}} = conn, %{"id" => id}) do
    product = Store.get_product(id, preload: [:stars, :reviews])

    conn
    |> render("product_show.html",
      product: product
    )
  end

  def index_services(%{assigns: %{company_id: company_id}} = conn, _params) do
    conn
    |> render("services.html")
  end

  def show_service(%{assigns: %{company_id: company_id}} = conn, %{"id" => id}) do
    service = Store.get_service(id, preload: [:stars, :reviews])

    conn
    |> render("service_show.html",
      service: service
    )
  end
end

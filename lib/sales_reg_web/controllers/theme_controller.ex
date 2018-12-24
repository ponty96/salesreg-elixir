defmodule SalesRegWeb.ThemeController do
  use SalesRegWeb, :controller

  def index(%{assigns: %{company_id: company_id}} = conn, _params) do
    featured_products = Store.load_featured_products(company_id)
    featured_services = Store.load_featured_services(company_id)
    categories = Store.home_categories(company_id)

    IO.inspect(categories, label: "categories")
    IO.inspect(Enum.slice(categories, 3, 10), label: "Enum.slice(@categories, 3, 10)")

    conn
    |> render("index.html",
      featured_products: featured_products,
      featured_services: featured_services,
      categories: categories
    )
  end
end

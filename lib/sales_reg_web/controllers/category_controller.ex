defmodule SalesRegWeb.CategoryController do
  use SalesRegWeb, :controller

  def index(%{assigns: %{company_id: company_id}} = conn, _params) do
    categories = Store.paginated_categories(company_id)

    conn
    |> render("categories.html",
      categories: categories
    )
  end

  def show(%{assigns: %{company_id: company_id}} = conn, %{"id" => id}) do
    category = Store.get_category(id, preload: [products: [:stars, :reviews], services: [:stars, :reviews]])

    conn
    |> render("category_show.html",
      category: category,
      products: category.products,
      services: category.services
    )
  end
end

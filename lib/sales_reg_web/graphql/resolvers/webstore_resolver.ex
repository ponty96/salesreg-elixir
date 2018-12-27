defmodule SalesRegWeb.GraphQL.Resolvers.WebStoreResolver do
  use SalesRegWeb, :context

  def home_page_query(params, resolution) do
    company = resolution.context.company

    home_data = %{
      categories: Store.home_categories(company.id),
      featured_products: Store.load_featured_products(company.id),
      featured_services: Store.load_featured_services(company.id),
      company: company
    }

    {:ok, home_data}
  end
end

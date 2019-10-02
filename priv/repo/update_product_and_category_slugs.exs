alias SalesReg.Repo
alias SalesReg.Store
alias SalesReg.Store.{Product, Category}

# get all company product
# run update method

defmodule UpdateProduct do
  def transform_product(product) do
    Map.from_struct(product)
    |> Map.put(:categories, Enum.map(product.categories, & &1.id))
    |> Map.put(:tags, Enum.map(product.tags, & &1.id))
  end
end

Product
|> Repo.all()
|> Repo.preload([
  :items,
  :stars,
  :tags,
  :categories,
  :user,
  :company
])
|> Enum.map(&Store.update_product_details(&1.id, UpdateProduct.transform_product(&1)))

Repo.all(Category)
|> Enum.map(&Store.update_category(&1, %{title: &1.title, company_id: &1.company_id}))

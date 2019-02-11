alias SalesReg.Repo
alias SalesReg.Store
alias SalesReg.Store.{Product, Category}

# get all company product
# run update method

defmodule UpdateProduct do
  def transform_product(product) do
    Map.from_struct(product)
    |> Map.put(:categories, Enum.map(product.categories, &(&1.id)))
    |> Map.put(:tags, Enum.map(product.tags, &(&1.id)))
    |> Map.put(:option_values, Enum.map(product.option_values, &(transform_option_value(&1))))
  end

  def transform_option_value(option_value) do
   option_value = Map.from_struct(option_value)
   %{
     name: option_value.name,
     company_id: option_value.company_id,
     option_id: option_value.option_id
   }
  end
end

Product
|> Repo.all()
|> Repo.preload([:option_values, :items, :stars, :tags, :categories, :user, :company, :product_group])
|> Enum.map(&Store.update_product_details(&1.id, UpdateProduct.transform_product(&1)))

Repo.all(Category)
|> Enum.map(&(Store.update_category(&1, %{title: &1.title, company_id: &1.company_id})))

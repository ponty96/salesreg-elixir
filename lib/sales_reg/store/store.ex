defmodule SalesReg.Store do
  @moduledoc """
  The Store context.
  """
  use SalesRegWeb, :context
  alias Dataloader.Ecto, as: DataloaderEcto

  use SalesReg.Context, [
    Product,
    Service,
    Category,
    Tag,
    Invoice
  ]

  def data do
    DataloaderEcto.new(Repo, query: &query/2)
  end

  def query(queryable, _) do
    queryable
  end

  def load_categories(%{categories: categories}) do
    load_categories(%{"categories" => categories})
  end

  def load_categories(%{"categories" => []}) do
    []
  end

  def load_categories(%{"categories" => categories_ids}) do
    all_categories(categories_ids)
  end

  def load_categories(%{categories: []}) do
    []
  end

  def load_categories(%{categories: categories_ids}) do
    all_categories(categories_ids)
  end

  defp all_categories(categories_ids) do
    Repo.all(
      from(
        c in Category,
        where: c.id in ^categories_ids
      )
    )
  end

  def load_tags(%{"tags" => tag_names, "company_id" => company_id}) do
    gen_company_tags(tag_names, [], company_id)
  end

  def load_tags(%{tags: tag_names, company_id: company_id}) do
    gen_company_tags(tag_names, [], company_id)
  end

  defp gen_company_tags([], acc, _company_id) do
    acc
  end

  defp gen_company_tags([tag_name | tail], acc, company_id) do
    gen_company_tags(tail, acc ++ [tag_struct(tag_name, company_id)], company_id)
  end

  defp tag_struct(tag_name, company_id) do
    tag =
      Tag
      |> where([t], t.name == ^tag_name)
      |> where([t], t.company_id == ^company_id)
      |> Repo.one()

    case tag do
      %Tag{} ->
        tag

      _ ->
        tag_params = %{
          name: tag_name,
          company_id: company_id
        }

        {:ok, tag} = Store.add_tag(tag_params)
        tag
    end
  end

  def update_product_inventory(:increment, order_items) when is_list(order_items) do
    Enum.map(order_items, fn order_item ->
      if order_item.product_id do
        increment_product_sku(order_item.product_id, order_item.quantity)
      end

      order_item
    end)
  end

  def update_product_inventory(:decrement, order_items) when is_list(order_items) do
    Enum.map(order_items, fn order_item ->
      if order_item.product_id do
        decrement_product_sku(order_item.product_id, order_item.quantity)
      end

      order_item
    end)
  end

  defp increment_product_sku(product_id, quantity) do
    product = get_product(product_id)
    quantity = String.to_integer(quantity)
    product_stock_quantity = String.to_integer(product.stock_quantity)
    update_product(product, %{"stock_quantity" => "#{quantity + product_stock_quantity}"})
  end

  defp decrement_product_sku(product_id, quantity) do
    product = get_product(product_id)
    quantity = String.to_integer(quantity)
    product_stock_quantity = String.to_integer(product.stock_quantity)

    update_product(product, %{"stock_quantity" => "#{product_stock_quantity - quantity}"})
  end

  def list_featured_items(company_id) do
    Product
    |> join(:inner, [p], s in Service)
    |> where([p, s], p.is_featured == true and s.is_featured == true)
    |> where([p, s], p.company_id == ^company_id and s.company_id == ^company_id)
    |> select([p, s], {p.name, s.name, p.is_top_rated_by_merchant, s.is_top_rated_by_merchant})
    |> order_by([p, s], asc: p.is_featured, asc: s.is_featured)
    |> Repo.all()
  end

  def list_top_rated_items(company_id) do
    Product
    |> join(:inner, [p], s in Service)
    |> where([p, s], p.is_top_rated_by_merchant == true and s.is_top_rated_by_merchant == true)
    |> where([p, s], p.company_id == ^company_id and s.company_id == ^company_id)
    |> select([p, s], {p.name, s.name, p.is_top_rated_by_merchant, s.is_top_rated_by_merchant})
    |> order_by([p, s], asc: p.is_top_rated_by_merchant, asc: s.is_top_rated_by_merchant)
    |> Repo.all()
  end
end

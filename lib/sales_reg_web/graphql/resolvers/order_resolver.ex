defmodule SalesRegWeb.GraphQL.Resolvers.OrderResolver do
  use SalesRegWeb, :context

  def add_purchase(%{purchase: params}, _res) do
    cost = calc_purchase_cost(params)

    new_params =
      Map.put_new(params, :amount, cost)
      |> stringify_keys()

    Order.add_purchase(new_params)
  end

  def update_purchase(%{purchase: params, purchase_id: id}, _res) do
    cost = calc_purchase_cost(params)

    new_params =
      Map.put_new(params, :amount, cost)
      |> stringify_keys()

    Order.get_purchase(id)
    |> Order.update_purchase(new_params)
  end

  def list_vendor_purchases(%{vendor_id: vendor_id}, _res) do
    purchases = Order.list_vendor_purchases(vendor_id)
    {:ok, purchases}
  end

  def cancel_purchase_order(%{purchase_id: id}, _res) do
    purchase = Order.get_purchase(id)
    attrs = %{status: "cancelled"}

    Order.update_purchase(purchase, attrs)
  end

  def list_company_purchases(%{company_id: company_id}, _res) do
    Order.list_company_purchases(company_id)
  end

  defp calc_purchase_cost(%{items: items}) do
    total_cost =
      items
      |> Enum.map(fn map ->
        calc_cost(map)
      end)
      |> Enum.reduce(fn x, acc ->
        x + acc
      end)

    Float.to_string(total_cost, decimals: 2)
  end

  defp stringify_keys(%{items: items} = params) do
    items =
      items
      |> Enum.map(fn map ->
        val_to_string(map)
      end)

    %{params | items: items}
  end

  defp calc_cost(map) do
    quantity = Map.get(map, :quantity)
    unit_price = Map.get(map, :unit_price)

    quantity * unit_price
  end

  defp val_to_string(map) do
    quantity =
      Map.get(map, :quantity)
      |> Float.to_string()

    unit_price =
      Map.get(map, :unit_price)
      |> Float.to_string()

    %{map | quantity: quantity, unit_price: unit_price}
  end
end

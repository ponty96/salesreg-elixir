defmodule SalesRegWeb.GraphQL.Resolvers.OrderResolver do
  use SalesRegWeb, :context

  def upsert_purchase(%{purchase: params, purchase_id: id}, _res) do
    # new_params = add_order_amount(params)

    Order.get_purchase(id)
    |> Order.update_purchase(params)
  end

  def upsert_purchase(%{purchase: params}, _res) do
    # new_params = add_order_amount(params)
    Order.add_purchase(params)
  end

  def list_company_purchases(%{company_id: company_id} = args, _res) do
    {:ok, purchases} = Order.list_company_purchases(company_id)

    purchases
    |> Absinthe.Relay.Connection.from_list(pagination_args(args))
  end

  def delete_purchase(%{purchase_id: purchase_id}, _res) do
    Order.get_purchase(purchase_id)
    |> Order.delete_purchase()
  end

  def upsert_sale(%{sale: params, sale_id: id}, _res) do
    # new_params = add_order_amount(params)

    Order.get_sale(id)
    |> Order.update_sale(params)
  end

  def upsert_sale(%{sale: params}, _res) do
    Order.add_sale(params)
  end

  def list_company_sales(%{company_id: company_id} = args, _res) do
    {:ok, sales} = Order.list_company_sales(company_id)

    sales
    |> Absinthe.Relay.Connection.from_list(pagination_args(args))
  end

  def delete_sale(%{sale_id: sale_id}, _res) do
    Order.get_sale(sale_id)
    |> Order.delete_sale()
  end

  def update_order_status(%{status: status, id: id, order_type: order_type}, _res) do
    Order.update_status(String.to_atom(order_type), id, status)
  end

  def update_invoice_due_date(%{invoice: params, invoice_id: id}, _res) do
    Order.get_invoice(id)
    |> Order.update_invoice(params)
  end

  def add_review(%{review: params}, _res) do
    Order.create_review(params)
  end

  def add_star(%{star: params}, _res) do
    Order.create_star(params)
  end

  def upsert_receipt(%{receipt: params}, _res) do
    current_date = Date.utc_today() |> Date.to_string()
    params = Map.put(params, :time_paid, current_date)
    create_receipt = Order.add_receipt(params)

    case create_receipt do
      {:ok, receipt} ->
        Order.supervise_pdf_upload(receipt)
        {:ok, receipt}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def delete_receipt(%{receipt_id: receipt_id}, _res) do
    Order.get_receipt(receipt_id)
    |> Order.delete_receipt()
  end

  defp pagination_args(args) do
    Map.take(args, [:first, :after, :last, :before])
  end

  # # Private functions
  # defp add_order_amount(params) do
  #   cost = calc_order_cost(params)

  #   Map.put_new(params, :amount, cost)
  #   |> stringify_keys()
  # end

  # defp calc_order_cost(%{items: items}) do
  #   total_cost =
  #     items
  #     |> Enum.map(fn map ->
  #       calc_cost(map)
  #     end)
  #     |> Enum.reduce(fn x, acc ->
  #       x + acc
  #     end)

  #   Float.to_string(total_cost, decimals: 2)
  # end

  # defp stringify_keys(%{items: items} = params) do
  #   items =
  #     items
  #     |> Enum.map(fn map ->
  #       val_to_string(map)
  #     end)

  #   %{params | items: items}
  # end

  # defp calc_cost(map) do
  #   quantity = Map.get(map, :quantity)
  #   unit_price = Map.get(map, :unit_price)

  #   quantity * unit_price
  # end

  # defp val_to_string(map) do
  #   quantity =
  #     Map.get(map, :quantity)
  #     |> Float.to_string()

  #   unit_price =
  #     Map.get(map, :unit_price)
  #     |> Float.to_string()

  #   %{map | quantity: quantity, unit_price: unit_price}
  # end
end

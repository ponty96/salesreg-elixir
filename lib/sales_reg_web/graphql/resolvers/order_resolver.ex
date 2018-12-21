defmodule SalesRegWeb.GraphQL.Resolvers.OrderResolver do
  use SalesRegWeb, :context

  def upsert_sale(%{sale: params, sale_id: id}, _res) do
    Order.get_sale(id)
    |> Order.update_sale(params)
  end

  def upsert_sale(%{sale: params}, _res) do
    Order.create_sale(params)
  end

  def list_company_sales(%{company_id: company_id} = args, _res) do
    {:ok, sales} = Order.list_company_sales(company_id)

    sales
    |> Absinthe.Relay.Connection.from_list(pagination_args(args))
  end

  def list_company_invoices(%{company_id: company_id} = args, _res) do
    {:ok, invoices} = Order.list_company_invoices(company_id)

    invoices
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
        sale = Order.preload_receipt(receipt).sale

        receipt.company_id
        |> Email.send_email("yc_payment_received", sale)
        
        {:ok, receipt}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def create_receipt(params, _res) do
    Order.create_receipt(params)
  end

  def delete_receipt(%{receipt_id: receipt_id}, _res) do
    Order.get_receipt(receipt_id)
    |> Order.delete_receipt()
  end

  defp pagination_args(args) do
    Map.take(args, [:first, :after, :last, :before])
  end
end

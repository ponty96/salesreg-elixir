defmodule SalesRegWeb.GraphQL.Resolvers.OrderResolver do
  use SalesRegWeb, :context
  alias SalesReg.Mailer.MerchantsToCustomers, as: M2C

  def upsert_sale(%{sale: params, sale_id: id}, _res) do
    Order.get_sale(id)
    |> Order.update_sale(params)
  end

  def upsert_sale(%{sale: params}, _res) do
    Order.create_sale(params)
  end

  def list_company_sales(%{company_id: company_id} = args, _res) do
    [company_id: company_id]
    |> Order.paginated_list_company_sales(pagination_args(args))
  end

  def list_company_invoices(%{company_id: company_id} = args, _res) do
    [company_id: company_id]
    |> Order.paginated_list_company_invoices(pagination_args(args))
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
        sale = Order.preload_receipt(receipt).sale
        M2C.send_payment_received_mail(sale, receipt)

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

  def list_company_activities(params, _res) do
    params.company_id
    |> Order.list_company_activities(params.contact_id, pagination_args(params))
  end

  def create_delivery_fee(%{delivery_fee: params}, _res) do
    Order.add_delivery_fee(params)
  end

  def list_company_delivery_fees(%{company_id: company_id}, _res) do
    [company_id: company_id]
    |> Order.list_company_delivery_fees()
  end

  def delete_delivery_fee(%{delivery_fee_id: delivery_fee_id}, _res) do
    Order.get_delivery_fee(delivery_fee_id)
    |> Order.delete_delivery_fee()
  end

  def nation_wide_delivery_fee_exists?(%{company_id: company_id}, _res) do
    {:ok, %{exist: Order.nation_wide_delivery_fee_exists?(company_id)}}
  end

  def create_delivery_date(%{delivery_date: params}, _res) do
    Order.add_delivery_date(params)
  end

  def confirm_delivery_date(%{delivery_date_id: delivery_date_id}, _res) do
    Order.confirm_delivery_date(delivery_date_id)
  end

  def update_delivery_date(%{delivery_date: params, delivery_date_id: id}, _res) do
    Order.get_delivery_date(id)
    |> Order.update_delivery_date(params)
  end
  
  def get_invoice_by_id(%{invoice_id: id}, _res) do
    {:ok, Order.get_invoice(id)}
  end

  def get_sale_by_id(%{sale_id: id}, _res) do
    {:ok, Order.get_sale(id)}
  end

  defp pagination_args(args) do
    Map.take(args, [:first, :after, :last, :before])
  end
end

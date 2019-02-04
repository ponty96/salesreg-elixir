defmodule SalesReg.WebhookHandler do
  use SalesRegWeb, :context

  def insert_receipt(%{"charged_amount" => amount} = data) do
    if receipt_exists?(data) do
      nil
    else
      get_sale_order(data)
      |> Order.insert_receipt(data["id"], to_string(amount), :card)
    end
  end

  defp get_sale_order(data) do
    [order_id, _timestamp] =
      data["txRef"]
      |> String.replace("_", " ")
      |> String.split()
    
    Order.get_sale(order_id)
  end

  defp receipt_exists?(data) do
    transaction_id = data["id"]

    receipt =
      transaction_id
      |> Order.get_receipt_by_transac_id()

    if receipt == nil do
      false
    else
      true
    end
  end
end

defmodule SalesReg.Order.OrderStateMachine do
  alias SalesReg.Order.{Purchase, Sale}
  alias SalesReg.{Order, Store}

  use Machinery,
    # The first state declared will be considered
    # the initial state
    states: ["pending", "processed", "delivering", "delivered", "recalled"],
    transitions: %{
      "pending" => "processed",
      "processed" => "delivering",
      "delivering" => "delivered",
      "delivered" => "recalled",
      "recalled" => "pending"
    }

  def persist(%Purchase{} = order, new_state) do
    {:ok, order} = Order.update_purchase(order, %{"status" => new_state})
    Map.put(order, :state, new_state)
  end

  def persist(%Sale{} = order, new_state) do
    {:ok, order} = Order.update_sale(order, %{"status" => new_state})
    Map.put(order, :state, new_state)
  end

  def persist(order, _new_state) do
    order
  end

  # increment inventory after a successful purchase
  def after_transition(%Purchase{} = order, "delivered") do
    # Write code to handle errors
    Store.update_product_inventory(:increment, order.items)
    order
  end

  # decrement inventory after a recalled order
  def after_transition(%Purchase{} = order, "recalled") do
    # Write code to handle errors
    Store.update_product_inventory(:decrement, order.items)
    order
  end

  # decrement inventory after a sales order has been processed
  def after_transition(%Sale{} = order, "processed") do
    invoice_params =  build_invoice_params(order)
    Store.add_invoice(invoice_params)
    # Write code to handle errors
    Store.update_product_inventory(:decrement, order.items)
    order
  end

  # increment inventory after a recalled sale order
  def after_transition(%Sale{} = order, "recalled") do
    # Write code to handle errors
    Store.update_product_inventory(:increment, order.items)
    order
  end

  defp build_invoice_params(order) do
    %{
      due_date: "#{order.date}",
      sale: "#{order.id}",
      user: "#{order.user_id}",
      company: "#{order.company_id}"
    }
  end
end

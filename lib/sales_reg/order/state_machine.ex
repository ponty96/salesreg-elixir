defmodule SalesReg.Order.OrderStateMachine do
  alias SalesReg.Order.{Sale}
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

  def persist(%Sale{} = order, new_state) do
    {:ok, order} = Order.update_sale(order, %{"status" => new_state})
    Map.put(order, :state, new_state)
  end

  def persist(order, _new_state) do
    order
  end

  # decrement inventory after a sales order has been processed
  def after_transition(%Sale{} = order, "processed") do
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
end

defmodule SalesReg.Order.OrderStateMachine do
  alias SalesReg.Order.Purchase
  alias SalesReg.Order.Sale
  alias SalesReg.Order
  alias SalesReg.Store

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
end

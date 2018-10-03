defmodule SalesReg.Order.OrderStateMachine do
  alias SalesReg.Order.Purchase
  alias SalesReg.Order.Sale
  alias SalesReg.Order

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
end

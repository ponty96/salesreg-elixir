defmodule SalesReg.Order.OrderStateMachine do
  @moduledoc """
  State machine for Sale Schema status
  """
  use SalesRegWeb, :context
  alias SalesReg.Mailer.MerchantsToCustomers, as: M2C

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
    {:ok, order} = Order.update_sale(order, %{status: new_state})
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

  # send email when order is pending
  def after_transition(%Sale{} = order, "pending") do
    # Write code to handle errors
    M2C.send_pending_order_mail(order)
    order
  end

  # send email to customer when sale order is delivering
  def after_transition(%Sale{} = order, "delivering") do
    # Write code to handle errors
    M2C.send_delivering_order_mail(order)
    order
  end

  # send email to customer when order is delivered
  def after_transition(%Sale{} = order, "delivered") do
    # Write code to handle errors
    M2C.send_delivered_order_mail(order)
    order
  end
end

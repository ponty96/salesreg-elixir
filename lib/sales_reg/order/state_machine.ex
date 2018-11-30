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
    invoice_params = build_invoice_params(order)
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

  # A review and star can only be made after a sale order is delivered
  def after_transition(%Sale{} = order, "delivered") do
    params = build_review_and_star_params(order)

    Order.add_review(params)
    Order.add_star(params)

    order
  end

  defp build_review_and_star_params(order, user_review \\ "") do
    %{
      text: user_review,
      sale_id: order.sale_id,
      product_id: order.product_id,
      contact_id: order.contact_id
    }
  end

  


  defp build_invoice_params(order) do
    %{
      due_date: order.date,
      sale_id: order.id,
      user_id: order.user_id,
      company_id: order.company_id
    }
  end
end

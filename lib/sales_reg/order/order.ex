defmodule SalesReg.Order do
  @moduledoc """
  The Order context.
  """

  import Ecto.Query, warn: false
  use SalesRegWeb, :context
  alias Dataloader.Ecto, as: DataloaderEcto
  alias SalesReg.Order.OrderStateMachine

  use SalesReg.Context, [
    Purchase,
    Sale,
    Invoice,
    Review,
    Star
  ]

  def data do
    DataloaderEcto.new(Repo, query: &query/2)
  end

  def query(queryable, _) do
    queryable
  end

  def preload_order(order) do
    Repo.preload(order, items: [:product, :service])
  end

  def update_status(:purchase, order_id, new_status) do
    purchase_order = get_purchase(order_id) |> preload_order()
    purchase_order = Map.put(purchase_order, :state, purchase_order.status)

    case Machinery.transition_to(purchase_order, OrderStateMachine, new_status) do
      {:ok, updated} ->
        {:ok, updated}

      {:error, error} ->
        IO.inspect(error, label: "transition state error")
        {:error, error}
    end
  end

  def update_status(:sale, order_id, new_status) do
    sale_order = get_sale(order_id) |> preload_order()
    sale_order = Map.put(sale_order, :state, sale_order.status)

    case Machinery.transition_to(sale_order, OrderStateMachine, new_status) do
      {:ok, updated} ->
        {:ok, updated}

      {:error, error} ->
        IO.inspect(error, label: "transition state error")
        {:error, error}
    end
  end

  def processed_sale_orders() do
    Sale
    |> where([s], s.status == "processed")
    |> Repo.all()
  end

  def create_review(%{"sale_id" => sale_id, "contact_id" => contact_id, "product_id" => product_id} = params) do
    with {:ok, sale} <- get_sale(sale_id),
      true <- sale.contact_id == contact_id,
      {:ok, _item} <- find_in_items(sale.items, :product, product_id)
    do
      Order.add_review(params)
    else
      {:ok, "not found"} -> {:error, [%{key: "product_id", message: "product not found in sales item"}]}
      false -> {:error, [%{key: "contact_id", message: "contact does not have the right to review this item"}]}
      nil -> {:error, [%{key: "sale_id", message: "sale order does not exist"}]}
    end
  end

  def create_review(%{"sale_id" => sale_id, "contact_id" => contact_id, "service_id" => service_id} = params) do
    with sale <- get_sale(sale_id),
      true <- sale.contact_id == contact_id,
      {:ok, _item} <- find_in_items(sale.items, :service, service_id)
    do
      Order.add_review(params)
    else
      {:ok, "not found"} -> {:error, [%{key: "service_id", message: "service not found in sales item"}]}
      false -> {:error, [%{key: "contact_id", message: "contact does not have the right to review this item"}]}
      nil -> {:error, [%{key: "sale_id", message: "sale order does not exist"}]}
    end
  end

  def create_star(%{"sale_id" => sale_id, "contact_id" => contact_id, "product_id" => product_id} = params) do
    with sale <- get_sale(sale_id),
      true <- sale.contact_id == contact_id,
      {:ok, _item} <- find_in_items(sale.items, :product, product_id)
    do
      Order.add_star(params)
    else
      {:ok, "not found"} -> {:error, [%{key: "product_id", message: "product not found in sales item"}]}
      false -> {:error, [%{key: "contact_id", message: "contact does not have the right to review this item"}]}
      nil -> {:error, [%{key: "sale_id", message: "sale order does not exist"}]}
    end
  end

  def create_star(%{"sale_id" => sale_id, "contact_id" => contact_id, "service_id" => service_id}  = params) do
    with sale <- get_sale(sale_id),
      true <- sale.contact_id == contact_id,
      {:ok, _item} <- find_in_items(sale.items, :service, service_id)
    do
      Order.add_star(params)
    else
      {:ok, "not found"} -> {:error, [%{key: "service_id", message: "service not found in sales item"}]}
      false -> {:error, [%{key: "contact_id", message: "contact does not have the right to review this item"}]}
      nil -> {:error, [%{key: "sale_id", message: "sale order does not exist"}]}
    end
  end

  def find_in_items(items, :product, product_id) do
    {:ok, Enum.find(items, "not found", fn item -> item.product_id == product_id end)}
  end

  def find_in_items(items, :service, service_id) do
    {:ok, Enum.find(items, "not found", fn item -> item.service_id == service_id end)}
  end
end
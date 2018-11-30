defmodule SalesReg.Order do
  @moduledoc """
  The Order context.
  """

  import Ecto.Query, warn: false
  use SalesRegWeb, :context
  alias Dataloader.Ecto, as: DataloaderEcto
  alias SalesReg.Order.OrderStateMachine
  alias SalesReg.Repo

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

  def create_review(%{"sale_id" => sale_id, "contact_id" => contact_id, "product_id" => product_id}) do
    sale =
      Order.Sale
      |> where([sale], sale.id == ^sale_id)
      |> where([sale], sale.contact_id == ^contact_id)
      |> join(:left, [sale], items in assoc(sale, :items))
      |> join(:left, [sale, items], product_id in assoc(items, :product_id))
      |> preload([sale, items, product_id], items: {items, product_id: product_id})
      |> Repo.one!()
      |> Order.add_review()
  end

  def create_review(%{"sale_id" => sale_id, "contact_id" => contact_id, "service_id" => service_id}) do
    sale =
      Order.Sale
      |> where([sale], sale.id == ^sale_id)
      |> where([sale], sale.contact_id == ^contact_id)
      |> join(:left, [sale], items in assoc(sale, :items))
      |> join(:left, [sale, items], service_id in assoc(items, :service_id))
      |> preload([sale, items, service_id], items: {items, service_id: service_id})
      |> Repo.one!()
      |> Order.add_review()
  end
end

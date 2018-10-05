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
    Sale
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
end

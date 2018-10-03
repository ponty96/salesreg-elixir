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

  def update_status(:purchase, order_id, new_status) do
    purchase_order = get_purchase(order_id)
    purchase_order = Map.put(purchase_order, :state, purchase_order.status)

    case Machinery.transition_to(purchase_order, OrderStateMachine, new_status) do
      {:ok, updated} ->
        {:ok, updated}

      {:error, error} ->
        IO.inspect(error, label: "transition state error")
        {:error, error}
    end
  end
end

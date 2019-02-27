defmodule SalesReg.Notifications do
  @moduledoc """
  The Notifications context.
  """
  use SalesRegWeb, :context
  alias Dataloader.Ecto, as: DataloaderEcto

  use SalesReg.Context, [
    Notification,
    NotificationItem
  ]

  def data do
    DataloaderEcto.new(Repo, query: &query/2)
  end

  def query(queryable, _) do
    queryable
  end

  def create_notification(params, {:order, order}, action_type) when is_atom(action_type) do
    params
    |> Map.put(:action_type, Atom.to_string(action_type))
    |> Map.put(:element, "order")
    |> Map.put(:element_id, order.id)
    |> Notifications.add_notification()
  end

  def create_notification(params, {:invoice, invoice}, action_type) when is_atom(action_type) do
    params
    |> Map.put(:action_type, Atom.to_string(action_type))
    |> Map.put(:element, "invoice")
    |> Map.put(:element_id, invoice.id)
    |> Notifications.add_notification()
  end

  def get_unread_company_notifications_count(clauses) do
    {:ok, notifications} =
      clauses
      |> Notifications.list_company_notifications()

    {:ok, Enum.count(notifications)}
  end
end

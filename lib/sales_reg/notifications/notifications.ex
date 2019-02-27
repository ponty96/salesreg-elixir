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

  def get_unread_company_notifications_count(clauses) do
    {:ok, notifications} = 
      clauses
      |> Notifications.list_company_notifications()

    {:ok, Enum.count(notifications)}
  end
end

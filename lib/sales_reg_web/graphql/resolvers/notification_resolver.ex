defmodule SalesRegWeb.GraphQL.Resolvers.NotificationResolver do
  @moduledoc """
  Notification Resolver
  """
  use SalesRegWeb, :context

  # MUTATIONS
  def change_notification_read_status(%{notification_id: id}, _res) do
    id
    |> Notifications.get_notification()
    |> Notifications.update_notification(%{read_status: "read"})
  end

  def upsert_mobile_device(%{mobile_device: params}, _res) do
    Notifications.upsert_mobile_device(params)
  end

  def disable_mobile_device_notification(params, _res) do
    Notifications.disable_mobile_device_notification(params)
  end

  # QUERIES
  def list_company_notifications(%{company_id: company_id} = args, _res) do
    [company_id: company_id]
    |> Notifications.paginated_list_company_notifications(pagination_args(args))
  end

  def get_unread_company_notifications_count(%{company_id: company_id}, _res) do
    [company_id: company_id, read_status: "unread"]
    |> Notifications.get_unread_company_notifications_count()
  end

  defp pagination_args(args) do
    Map.take(args, [:first, :after, :last, :before])
  end
end

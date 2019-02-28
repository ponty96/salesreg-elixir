defmodule SalesReg.Notifications do
  @moduledoc """
  The Notifications context.
  """
  use SalesRegWeb, :context
  alias Dataloader.Ecto, as: DataloaderEcto

  use SalesReg.Context, [
    Notification,
    NotificationItem,
    MobileDevice
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

    {:ok, %{data: %{count: Enum.count(notifications)}}}
  end

  def upsert_mobile_device(params) do
    case get_mobile_device_by_device_token(params) do
      %MobileDevice{} = mobile_device ->
        mobile_device
        |> Notifications.update_mobile_device(params)

      nil ->
        Notifications.add_mobile_device(params)
    end
  end

  def disable_mobile_device_notification(params) do
    case get_mobile_device_by_device_token(params) do
      %MobileDevice{} = mobile_device ->
        mobile_device
        |> Notifications.update_mobile_device(%{notification_enabled: false})

      nil ->
        {:error,
         [
           %{
             key: "mobile_device",
             message: "A mobile device does not exist for this user"
           }
         ]}
    end
  end

  defp get_mobile_device_by_device_token(params) do
    from(m in MobileDevice,
      where: m.user_id == ^params.user_id,
      where: m.device_token == ^params.device_token
    )
    |> Repo.one()
  end
end

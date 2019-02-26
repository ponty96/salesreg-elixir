defmodule SalesReg.Notifications.NotificationItem do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "notification_items" do
    field(:changed_to, :string)
    field(:current, :string)
    field(:item_type, :string)
    field(:item_id, :string)
    belongs_to(:notification, SalesReg.Notifications.Notification)

    timestamps()
  end

  @fields [:current, :changed_to]
  @required_fields [:item_type, :item_id]
  @doc false
  def changeset(notification_item, attrs) do
    notification_item
    |> cast(attrs, @fields ++ @required_fields)
    |> validate_required(@required_fields)
  end
end

defmodule SalesReg.Notifications.Notification do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "notifications" do
    field(:action_type, :string)
    field(:delivery_channel, :string, default: "push")
    field(:delivery_status, :string, default: "unsent")
    field(:element, :string)
    field(:element_id, :string)
    field(:read_status, :string, default: "unread")
    belongs_to(:company, SalesReg.Business.Company)
    belongs_to(:actor, SalesReg.Accounts.User)
    has_many(:notification_items, SalesReg.Notifications.NotificationItem, on_replace: :delete)

    timestamps()
  end

  @fields [:delivery_channel, :delivery_status, :read_status]
  @required_fields [:element, :element_id, :action_type, :actor_id, :company_id]

  @doc false
  def changeset(notification, attrs) do
    notification
    |> cast(attrs, @fields ++ @required_fields)
    |> validate_required(@required_fields)
    |> cast_assoc(:notification_items)
    |> IO.inspect label: "changeset"
  end
end

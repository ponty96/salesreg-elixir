defmodule SalesReg.Notifications.MobileDevice do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "mobile_devices" do
    field(:app_version, :string)
    field(:brand, :string)
    field(:build_number, :string)
    field(:device_token, :string)
    field(:mobile_os, :string)
    field(:notification_enabled, :boolean)
    belongs_to(:user, SalesReg.Accounts.User)

    timestamps()
  end

  @fields [
    :mobile_os,
    :brand,
    :build_number,
    :device_token,
    :app_version,
    :notification_enabled
  ]

  @required_fields [
    :user_id,
    :notification_enabled
  ]

  @doc false
  def changeset(mobile_device, attrs) do
    mobile_device
    |> cast(attrs, @fields ++ @required_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:device_token,
      name: :users_device_token_user_id_index,
      message: "This device token already exists for this user"
    )
  end
end

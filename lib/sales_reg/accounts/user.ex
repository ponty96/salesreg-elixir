defmodule SalesReg.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field(:date_of_birth, :string)
    field(:email, :string)
    field(:first_name, :string)
    field(:gender, :string)
    field(:last_name, :string)
    field(:hashed_password, :string)

    # required for registration
    field(:password, :string, virtual: true)
    field(:password_confirmation, :string, virtual: true)

    field(:profile_pciture, :string)

    timestamps()
  end

  @required_fields [:first_name, :last_name, :date_of_birth, :email]
  @registration_fields [:hashed_password, :password, :password_confirmation]

  @fields [:profile_picture]

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, @required_fields ++ @fields)
    |> validate_required(@required_fields)
  end

  def registration_changeset(user, attrs) do
    user
    |> cast(attrs, @required_fields ++ @registration_fields)
    |> validate_required(@required_fields ++ @registration_fields)
    |> validate_password
    |> set_password
  end

  defp validate_password(changeset) do
    if get_field(changeset, :password) == get_field(changeset, :password_confirmation) do
      changeset
    else
      add_error(changeset, :password_confirmation, "password do not match")
    end
  end

  defp set_password(changeset) do
    changeset
    |> hash_password
  end

  defp hash_password(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :encrypted_password, Comeonin.Bcrypt.hashpwsalt(password))
      _ ->
        changeset
    end
  end
end

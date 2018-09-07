defmodule SalesReg.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  alias SalesReg.Repo

  alias SalesReg.Business.{Company}

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
    field(:profile_picture, :string)

    has_one(:company, Company, foreign_key: :owner_id)
    has_many(:contacts, SalesReg.Business.Contact)
    has_one(:phone, SalesReg.Business.Phone, on_replace: :delete)
    has_one(:location, SalesReg.Business.Location, on_replace: :delete)

    timestamps()
  end

  @required_fields [:email, ]
  @registration_fields [:password, :password_confirmation]

  @fields [:profile_picture, :date_of_birth]
  @update_fields [:first_name, :last_name, :gender]

  @doc false
  def changeset(user, attrs) do
    user
    |> Repo.preload([:phone, :location])
    |> cast(attrs, @update_fields ++ @fields)
    |> validate_required(@update_fields ++ [:date_of_birth])
    |> cast_assoc(:phone)
    |> cast_assoc(:location)
  end

  def registration_changeset(user, attrs) do
    user
    |> cast(attrs, @required_fields ++ @registration_fields ++ @update_fields)
    |> validate_required(@required_fields ++ @registration_fields ++ @update_fields)
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
    |> validate_password
    |> set_password
    |> cast_assoc(:company)
    |> cast_assoc(:phone)
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
        put_change(changeset, :hashed_password, Comeonin.Bcrypt.hashpwsalt(password))

      _ ->
        changeset
    end
  end
end

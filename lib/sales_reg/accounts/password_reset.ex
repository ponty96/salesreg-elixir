defmodule SalesReg.Accounts.PasswordReset do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "password_reset" do
    belongs_to(:users, SalesReg.Accounts.User)

    timestamps()
  end

  @doc false
  def changeset(password_reset, attrs) do
    password_reset
    |> cast(attrs, [:user_id])
    |> validate_required(:user_id)
  end

  def delete_changeset(password_reset, attrs) do
    password_reset
    |> cast(%{}, [])
  end
end

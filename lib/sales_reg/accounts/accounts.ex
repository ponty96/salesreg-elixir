defmodule SalesReg.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias SalesReg.Repo
  alias SalesReg.Accounts.User

  def get_user(id), do: Repo.get(User, id)

  def get_user_by_email(value), do: Repo.get_by(User, email: value)

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end
end

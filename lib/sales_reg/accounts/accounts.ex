defmodule SalesReg.Accounts do
  @moduledoc """
  The Accounts context.
  """
  use SalesRegWeb, :context
  alias Dataloader.Ecto, as: DataloaderEcto
  alias SalesReg.ImageUpload

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

  def data do
    DataloaderEcto.new(Repo, query: &query/2)
  end

  def query(queryable, _) do
    queryable
  end
end

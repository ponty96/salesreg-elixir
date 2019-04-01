defmodule SalesReg.Accounts do
  @moduledoc """
  The Accounts context.
  """
  use SalesRegWeb, :context
  alias Dataloader.Ecto, as: DataloaderEcto

  def get_user(id), do: Repo.get(User, id)

  def get_user_by_email(value), do: Repo.get_by(User, email: value)

  def get_user_company(user) do
    Repo.preload(user, [:company]).company
  end

  def register_user(user_params) do
    user_params =
      user_params
      |> Map.put_new(:hashed_str, gen_hash(user_params.first_name))

    case create_user(user_params) do
      {:ok, user} ->
        query_params_str =
          %{
            "email" => user.email,
            "hash" => user.hashed_str
          }
          |> URI.encode_query()

        link = "#{System.get_env("APP_URL")}confirm-email?#{query_params_str}"
        sub = "Confirm email"

        html_body =
          return_file_content("yc_email_confirm_email")
          |> EEx.eval_string(confirm_email_link: link)

        Email.send_email(user.email, sub, html_body)
        Authentication.sign_in(user)

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def confirm_user_email(params) do
    with %User{} = user <- get_user_by_email(params["email"]),
         true <- validate_hash(params, user) do
      user
      |> User.confirm_email_changeset(%{confirmed_email?: true})
      |> Repo.update()
    else
      nil ->
        {:error, "No resource was found for this operation"}

      false ->
        {:error, "Invalid hash"}
    end
  end

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

  defdelegate return_file_content(type), to: Business, as: :return_file_content

  defp validate_hash(params, user) do
    if user.hashed_str == params["hash"] do
      true
    else
      false
    end
  end

  defp gen_hash(str) do
    :crypto.hash(:md5, str)
    |> Base.encode16(case: :lower)
  end
end

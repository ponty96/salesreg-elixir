defmodule SalesRegWeb.Types do
  @moduledoc """
  	Module contains all GraphQL Object Types
  """

  use Absinthe.Schema.Notation
  use Absinthe.Ecto, repo: SalesReg.Repo
  alias SalesReg.Accounts.User

  import_types(Absinthe.Type.Custom)

  @desc """
    User field type
  """

  object :user do
    field(:id, :id)
    field(:date_of_birth, :string)
    field(:email, non_null(:string))
    field(:first_name, :string)
    field(:gender, :string)
    field(:last_name, :string)
    field(:profile_picture, :string)

    field(:inserted_at, :naive_datetime)
    field(:updated_at, :naive_datetime)
  end

  input_object :user_input do
    field(:date_of_birth, :string)
    field(:email, non_null(:string))
    field(:first_name, :string)
    field(:gender, :string)
    field(:last_name, :string)
    field(:password, non_null(:string))
    field(:password_confirmation, non_null(:string))
    field(:profile_picture, :string)
  end

  @desc """
    Consistent Type for Mutation Response
  """
  object :mutation_response do
    field(:success, non_null(:boolean))
    field(:field_errors, list_of(:error))
    field(:data, :mutated_data)
  end

  union :mutated_data do
    description("A mutated data")

    types([:user, :authorization])

    resolve_type(fn
      %User{}, _ -> :user
      %{user: %User{}}, _ -> :authorization
    end)
  end

  object :error do
    field(:message, :string)
    field(:key, non_null(:string))
  end

  object :authorization do
    field(:jwt, non_null(:string))
    field(:user, non_null(:user))
  end
end

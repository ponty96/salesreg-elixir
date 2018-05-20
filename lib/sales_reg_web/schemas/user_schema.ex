defmodule SalesRegWeb.Schemas.User do
  @moduledoc """
    GraphQL Schemas for User
  """
  use Absinthe.Schema.Notation
  alias SalesRegWeb.Helpers.MutationResolver
  alias SalesReg.Authentication
  alias SalesReg.Accounts
  alias SalesRegWeb.Helpers.Authorization

  @desc """
  query a user
  """
  object :single_user do
    field :single_user, :user do
      arg(:id, non_null(:id))

      resolve(
        Authorization.access(:authenticated, fn _, %{id: id}, _ ->
          {:ok, Accounts.get_user!(id)}
        end)
      )
    end
  end

  @desc """
  mutation to start | register user
  """
  object :register_user do
    field :register_user, :mutation_response do
      arg(:user, non_null(:user_input))

      resolve(
        MutationResolver.handle_mutation(:public, fn _source, %{user: user_params}, _resolution ->
          Authentication.register(user_params)
        end)
      )
    end
  end

  object :login_user do
    field :login_user, :mutation_response do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))

      resolve(
        MutationResolver.handle_mutation(:public, fn _,
                                                     params = %{
                                                       email: _email,
                                                       password: _password
                                                     },
                                                     _resolution ->
          Authentication.login(params)
        end)
      )
    end
  end
end

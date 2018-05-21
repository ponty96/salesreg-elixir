defmodule SalesRegWeb.Schemas.User do
  @moduledoc """
    GraphQL Schemas for User
  """
  use Absinthe.Schema.Notation
  alias SalesRegWeb.Resolvers.UserResolver
  alias SalesRegWeb.Absinthe.Middleware

  @desc """
  query a user
  """
  object :single_user do
    field :single_user, :user do
      arg(:id, non_null(:id))

      middleware(Middleware)

      resolve(&UserResolver.get_user/2)
    end
  end

  @desc """
  mutation to start | register user
  """
  object :register_user do
    field :register_user, :mutation_response do
      arg(:user, non_null(:user_input))

      resolve(&UserResolver.register_user/2)
    end
  end

  object :login_user do
    field :login_user, :mutation_response do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))

      resolve(&UserResolver.login_user/2)
    end
  end
end

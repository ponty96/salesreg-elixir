defmodule SalesRegWeb.GraphQL.Schemas.UserSchema do
  @moduledoc """
    GraphQL Schemas for User
  """
  use Absinthe.Schema.Notation
  alias SalesRegWeb.GraphQL.Resolvers.UserResolver
  alias SalesRegWeb.GraphQL.MiddleWares.Authorize

  @desc """
  query a user
  """
  object :single_user do
    field :single_user, :user do
      arg(:id, non_null(:uuid))

      middleware(Authorize)
      resolve(&UserResolver.get_user/2)
    end
  end

  object :authentication_mutations do
    @desc """
    login a user
    """
    field :login_user, :mutation_response do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))

      resolve(&UserResolver.login_user/2)
    end

    @desc """
    verify access and refresh tokens based on 
    expiration time
    """
    field :verify_tokens, :mutation_response do
      arg(:access_token, non_null(:string))
      arg(:refresh_token, non_null(:string))

      resolve(&UserResolver.verify_tokens/2)
    end

    @desc """
    refresh a token
    """
    field :refresh_token, :mutation_response do
      arg(:refresh_token, non_null(:string))

      resolve(&UserResolver.refresh_token/2)
    end
  end
end

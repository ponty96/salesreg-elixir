defmodule SalesRegWeb.GraphQL.Schemas do
  @moduledoc false
  use Absinthe.Schema

  alias Absinthe.Type.Field

  alias SalesRegWeb.GraphQL.MiddleWares.{
    ChangesetErrors,
    MutationResponse
  }

  import_types(__MODULE__.DataTypes)
  import_types(__MODULE__.UserSchema)

  query do
    import_fields(:single_user)
  end

  mutation do
    import_fields(:register_user)
    import_fields(:login_user)
  end

  def middleware(middleware, field, object) do
    middleware
    |> apply(:errors, field, object)
    |> apply(:mutations, field, object)
  end

  defp apply(middleware, :errors, _field, %{identifier: :mutation}) do
    middleware ++ [ChangesetErrors]
  end

  defp apply(middleware, :mutations, _field, %{identifier: :mutation}) do
    middleware ++ [MutationResponse]
  end

  defp apply(middleware, _, _, _) do
    middleware
  end
end

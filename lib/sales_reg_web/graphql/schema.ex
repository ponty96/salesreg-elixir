defmodule SalesRegWeb.GraphQL.Schemas do
  @moduledoc false
  use Absinthe.Schema

  alias SalesRegWeb.GraphQL.MiddleWares.{
    ChangesetErrors,
    MutationResponse
  }

  alias Absinthe.Middleware.Dataloader, as: AbsintheDataloader
  alias Absinthe.Plugin, as: AbsinthePluginDefault

  import_types(__MODULE__.DataTypes)
  import_types(__MODULE__.UserSchema)
  import_types(__MODULE__.CompanySchema)
  import_types(__MODULE__.StoreSchema)

  query do
    import_fields(:single_user)
    import_fields(:product_queries)
  end

  mutation do
    import_fields(:register_company)
    import_fields(:login_user)
    import_fields(:product_mutations)
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

  def plugins do
    [AbsintheDataloader] ++ AbsinthePluginDefault.defaults()
  end

  def dataloader do
    Dataloader.new()
    |> Dataloader.add_source(SalesReg.Business, SalesReg.Business.data())
    |> Dataloader.add_source(SalesReg.Accounts, SalesReg.Accounts.data())
  end

  def context(ctx) do
    Map.put(ctx, :loader, dataloader())
  end
end

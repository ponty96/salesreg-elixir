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
  import_types(__MODULE__.BusinessSchema)
  import_types(__MODULE__.StoreSchema)
  import_types(__MODULE__.ContactSchema)
  import_types(__MODULE__.OrderSchema)
  import_types(__MODULE__.ExpenseSchema)
  import_types(__MODULE__.BankSchema)

  query do
    import_fields(:single_user)
    import_fields(:store_queries)
    import_fields(:contact_queries)
    import_fields(:order_queries)
    import_fields(:expense_queries)
  end

  mutation do
    import_fields(:company_mutations)
    import_fields(:authentication_mutations)
    import_fields(:store_mutations)
    import_fields(:contact_mutations)
    import_fields(:order_mutations)
    import_fields(:user_mutations)
    import_fields(:expense_mutations)
    import_fields(:bank_mutations)
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
    |> Dataloader.add_source(SalesReg.Order, SalesReg.Order.data())
    |> Dataloader.add_source(SalesReg.Store, SalesReg.Store.data())
  end

  def context(ctx) do
    Map.put(ctx, :loader, dataloader())
  end
end

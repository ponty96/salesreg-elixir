defmodule SalesRegWeb.GraphQL.Schemas.ExpenseSchema do
  @moduledoc """
    GraphQL Schemas for Expense
  """
  use Absinthe.Schema.Notation
  alias SalesRegWeb.GraphQL.Resolvers.ExpenseResolver
  alias SalesRegWeb.GraphQL.MiddleWares.Authorize
  
  ### MUTATIONS
  object :expense_mutations do
    @desc """
      upsert an expense
    """
    field :upsert_expense, :mutation_response do
      arg(:expense, non_null(:expense_input))
      arg(:expense_id, :uuid)

      middleware(Authorize)
      resolve(&ExpenseResolver.upsert_expense/2)
    end
  end

  ### QUERIES
  object :expense_queries do
    @desc """
      query all expenses of a company
    """
    field :company_expenses, list_of(:expense) do
      arg(:company_id, non_null(:uuid))

      middleware(Authorize)
      resolve(&ExpenseResolver.list_company_expenses/2)
    end
  end
end

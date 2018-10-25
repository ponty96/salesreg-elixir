defmodule SalesRegWeb.GraphQL.Schemas.BusinessSchema do
  @moduledoc """
    GraphQL Schemas for Company
  """
  use Absinthe.Schema.Notation
  alias SalesRegWeb.GraphQL.Resolvers.BusinessResolver
  alias SalesRegWeb.GraphQL.MiddleWares.Authorize

  ### MUTATIONS
  # Company Mutations
  object :company_mutations do
    @desc """
    mutation to start | register user
    """
    field :add_user_company, :mutation_response do
      arg(:user, non_null(:uuid))
      arg(:company, non_null(:company_input))

      middleware(Authorize)
      resolve(&BusinessResolver.register_company/2)
    end

    @desc """
    mutation to update | edit company
    """
    field :update_company, :mutation_response do
      arg(:id, non_null(:uuid))
      arg(:company, non_null(:company_input))

      resolve(&BusinessResolver.update_company/2)
    end
  end

  # Bank Mutations
  object :bank_mutations do
    @desc """
      upsert a bank
    """
    field :upsert_bank, :mutation_response do
      arg(:bank, non_null(:bank_input))
      arg(:bank_id, :uuid)

      middleware(Authorize)
      resolve(&BusinessResolver.upsert_bank/2)
    end

    @desc """
      mutation to delete bank
    """
    field :delete_bank, :mutation_response do
      arg(:bank_id, non_null(:uuid))

      middleware(Authorize)
      resolve(&BusinessResolver.delete_bank/2)
    end
  end

  # Expense Mutations
  object :expense_mutations do
    @desc """
      upsert an expense
    """
    field :upsert_expense, :mutation_response do
      arg(:expense, non_null(:expense_input))
      arg(:expense_id, :uuid)

      middleware(Authorize)
      resolve(&BusinessResolver.upsert_expense/2)
    end
  end

  ### QUERIES
  # Bank Queries
  object :bank_queries do
    @desc """
      query all banks of a company
    """
    field :company_banks, list_of(:bank) do
      arg(:company_id, non_null(:uuid))

      middleware(Authorize)
      resolve(&BusinessResolver.list_company_banks/2)
    end
  end

  # Expense Queries
  object :expense_queries do
    @desc """
      query all expenses of a company
    """
    field :company_expenses, list_of(:expense) do
      arg(:company_id, non_null(:uuid))

      middleware(Authorize)
      resolve(&BusinessResolver.list_company_expenses/2)
    end
  end

  # Tag Queries
  object :tag_queries do
    @desc """
      query all tags of a company
    """
    field :company_tags, list_of(:tag) do
      arg(:company_id, non_null(:uuid))

      middleware(Authorize)
      resolve(&BusinessResolver.list_company_tags/2)
    end
  end
end

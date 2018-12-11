defmodule SalesRegWeb.GraphQL.Schemas.ThemeSchema do
  @moduledoc """
    GraphQL Schemas for Theme
  """
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :classic
  alias SalesRegWeb.GraphQL.Resolvers.ThemeResolver
  alias SalesRegWeb.GraphQL.MiddleWares.Authorize

  ### QUERIES
  object :theme_queries do
    ### Template Theme queries

    @desc """
    list all templates
    """
    connection field(:list_templates, node_type: :template) do
      middleware(Authorize)
      resolve(&ThemeResolver.list_templates/2)
    end

    @desc """
    get company template
    """
    field :get_company_template_by_company_id, type: :company_template do
      arg(:company_id, non_null(:uuid))

      middleware(Authorize)
      resolve(&ThemeResolver.get_company_template_by_company_id/2)
    end

    @desc """
    select company template
    """
    field :set_company_template, type: :company_template do
      arg(:company_id, non_null(:uuid))
      arg(:company_template_id, non_null(:uuid))

      middleware(Authorize)
      resolve(&ThemeResolver.set_company_template/2)
    end
  end
end

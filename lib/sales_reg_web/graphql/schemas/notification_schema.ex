defmodule SalesRegWeb.GraphQL.Schemas.NotificationSchema do
  @moduledoc """
    GraphQL Schemas for Notification
  """
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :classic
  alias SalesRegWeb.GraphQL.Resolvers.NotificationResolver
  alias SalesRegWeb.GraphQL.MiddleWares.Authorize

  ### MUTATIONS
  object :notification_mutations do
    @desc """
      upsert a contact
    """
    field :change_notification_read_status, :mutation_response do
      arg(:notification_id, non_null(:uuid))

      middleware(Authorize)
      resolve(&NotificationResolver.change_notification_read_status/2)
    end
  end

  ### QUERIES
  object :notification_queries do
    @desc """
      query all notifications of a company
    """
    connection field(:list_company_notifications, node_type: :notification) do
      arg(:company_id, non_null(:uuid))

      middleware(Authorize)
      resolve(&NotificationResolver.list_company_notifications/2)
    end
  end
end

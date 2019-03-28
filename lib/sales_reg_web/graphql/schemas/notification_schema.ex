defmodule SalesRegWeb.GraphQL.Schemas.NotificationSchema do
  @moduledoc """
    GraphQL Schemas for Notification
  """
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :classic
  alias SalesRegWeb.GraphQL.MiddleWares.Authorize
  alias SalesRegWeb.GraphQL.Resolvers.NotificationResolver

  ### MUTATIONS
  object :notification_mutations do
    @desc """
      change notification read status
    """
    field :change_notification_read_status, :mutation_response do
      arg(:notification_id, non_null(:uuid))

      middleware(Authorize)
      resolve(&NotificationResolver.change_notification_read_status/2)
    end

    @desc """
      upsert mobile device
    """
    field :upsert_mobile_device, :mutation_response do
      arg(:mobile_device, non_null(:mobile_device_input))

      middleware(Authorize)
      resolve(&NotificationResolver.upsert_mobile_device/2)
    end

    @desc """
      disable mobile device notification
    """
    field :disable_mobile_device_notification, :mutation_response do
      arg(:device_token, non_null(:string))
      arg(:user_id, non_null(:uuid))

      middleware(Authorize)
      resolve(&NotificationResolver.disable_mobile_device_notification/2)
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

    @desc """
      query count for all unread notifications of a company
    """
    field(:get_unread_company_notifications_count, :integer) do
      arg(:company_id, non_null(:uuid))

      middleware(Authorize)
      resolve(&NotificationResolver.get_unread_company_notifications_count/2)
    end
  end
end

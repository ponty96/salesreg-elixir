defmodule SalesRegWeb.GraphQL.MiddleWares.Policy do
  @moduledoc """
  Absinthe Policy Middleware
  """
  @behaviour Absinthe.Middleware
  alias SalesReg.Policies.Policy
  require Logger

  def call(resolution, _config) do
    user_id = resolution.context.user_id
    company_id = resolution.context.company_id

    Logger.info(
      "Checking if user #{user_id} has permission to query/mutate data on on company #{company_id}"
    )

    case Policy.can?(:admin_task, user_id, company_id) do
      {:ok, _res} ->
        resolution

      {:error, error} ->
        resolution
        |> Absinthe.Resolution.put_result({:error, error})
    end
  end
end

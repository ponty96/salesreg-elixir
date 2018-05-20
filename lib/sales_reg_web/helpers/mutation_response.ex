defmodule SalesRegWeb.Helpers.MutationResponse do
  @moduledoc """
    This handles serializing of CRUD operation results
    into the GrapHQL MutationResponse Object
  """
  def build_response({:ok, data}) do
    {:ok, %{success: true, field_errors: [], data: data}}
  end

  def build_response({:error, errors}) do
    {:ok, %{success: false, field_errors: errors, data: nil}}
  end
end

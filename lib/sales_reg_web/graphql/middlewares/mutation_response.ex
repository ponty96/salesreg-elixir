defmodule SalesRegWeb.GraphQL.MiddleWares.MutationResponse do
  @moduledoc false

  @behaviour Absinthe.Middleware

  def call(%{value: %{errors: errors}} = res, _) do
    parse_errors(errors, res)
  end

  def call(%{errors: [%{key: _key, message: _message}] = errors} = res, _) do
    parse_errors(errors, res)
  end

  def call(res, _) do
    %{res | value: %{field_errors: [], success: true, data: res.value}}
  end

  defp parse_errors(errors, resolution) do
    %{resolution | value: %{field_errors: errors, success: false, data: nil}, errors: []}
  end
end

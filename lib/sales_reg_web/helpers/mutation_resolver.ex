defmodule SalesRegWeb.Helpers.MutationResolver do
  alias SalesRegWeb.Helpers.MutationResponse

  def handle_mutation(:public, fun) do
    fn source, params, resolution ->
      MutationResponse.build_response(fun.(source, params, resolution))
    end
  end

  def handle_mutation(:authenticated, fun) do
    fn source, params, %{context: %{current_user: current_user}} = info ->
      if current_user do
        MutationResponse.build_response(fun.(source, params, info))
      else
        {:error, "You are not authorized"}
      end
    end

    fn _, _, _ ->
      {:error, "You are not authorized"}
    end
  end
end

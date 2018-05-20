defmodule SalesRegWeb.Helpers.Authorization do
  def access(:authenticated, fun) do
    fn source, params, %{context: %{current_user: current_user}} = info ->
      if current_user do
        fun.(source, params, info)
      else
        {:error, "You are not authorized"}
      end
    end
  end

  def access(:public, fun) do
    fun
  end
end

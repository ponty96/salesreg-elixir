defmodule SalesReg.Base do
  @moduledoc """
   Base module for all general functions used across all contexts
  """
  use SalesRegWeb, :context

  def transform_string_keys_to_numbers(attrs, keys) when is_map(attrs) and is_list(keys) do
    map =
      attrs
      |> Map.take(keys)
      |> Enum.map(fn {key, val} ->
        {key, val |> Decimal.round(2)}
      end)
      |> Enum.into(%{}, fn {key, val} ->
        {key, val}
      end)

    Map.merge(attrs, map)
  end
end

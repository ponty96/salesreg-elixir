defmodule SalesReg.Base do
  @moduledoc """
   Base module for all general functions used across all contexts
  """
  use SalesRegWeb, :context
  alias Ecto.Changeset

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

  def validate_changeset_number_values(changeset, keys)
      when is_map(changeset) and is_list(keys) do
    changeset.changes
    |> Map.take(keys)
    |> Enum.filter(fn {_key, val} ->
      val <= 0
    end)
    |> Enum.reduce(changeset, fn {key, _val}, acc ->
      Changeset.add_error(acc, key, "Value must be greater than one")
    end)
  end

  def convert_string_keys_integer(attrs, keys) do
    attrs
    |> Map.take(keys)
    |> Enum.reduce(attrs, fn {key, str_val}, acc ->
      int_val = String.to_integer(str_val)
      Map.put(acc, key, int_val)
    end)
  end
end

defmodule SalesRegWeb.GraphQL.MiddleWares.ChangesetErrors do
  @moduledoc false
  alias Ecto.Changeset
  @behaviour Absinthe.Middleware

  def call(res, _) do
    with %{errors: [%Ecto.Changeset{} = changeset]} <- res do
      %{
        res
        | value: %{errors: transform_errors(changeset)},
          errors: []
      }
    end
  end

  def call(%{errors: [%Ecto.Changeset{} = changeset]} = res, _) do
    %{
      res
      | value: %{errors: transform_errors(changeset)},
        errors: []
    }
  end

  defp transform_errors(changeset) do
    changeset
    |> Changeset.traverse_errors(&format_error/1)
    |> Enum.map(fn {key, value} ->
      serialize_error(key, value)
    end)
    |> List.flatten()
  end

  def serialize_error(key, value) when is_list(value) do
    key
    |> check_values(value)
  end

  def serialize_error(_key, value) when is_map(value) do
    value
    |> Map.to_list()
    |> Enum.map(fn {assoc_key, value} ->
      %{
        key: "#{Atom.to_string(assoc_key)}",
        message: "#{value}"
      }
    end)
  end

  def serialize_error(key, value) do
    %{key: key, message: value}
  end

  def check_values(key, value) do
    case Enum.any?(value, &is_binary(&1)) do
      true ->
        %{key: camelize(Atom.to_string(key)), message: value}

      _ ->
        value
        |> Enum.filter(&(map_size(&1) >= 1))
        |> Enum.map(&Map.to_list(&1))
        |> List.flatten()
        |> Enum.map(fn {key, value} -> %{key: camelize(Atom.to_string(key)), message: value} end)
    end
  end

  @spec format_error(Changeset.error()) :: String.t()
  defp format_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end

  defp camelize(word, opts \\ [])

  defp camelize("_" <> word, opts) do
    "_" <> camelize(word, opts)
  end

  defp camelize(word, opts) do
    case opts |> Enum.into(%{}) do
      %{lower: true} ->
        {first, rest} = String.split_at(Macro.camelize(word), 1)
        String.downcase(first) <> rest

      _ ->
        Macro.camelize(word)
    end
  end
end

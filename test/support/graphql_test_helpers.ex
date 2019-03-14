defmodule SalesRegWeb.GraphqlTestHelpers do
  alias SalesRegWeb.Authentication

  def query_skeleton(query, variables) when is_map(variables) do
    %{
      "query" => "#{query}",
      "variables" => "#{Jason.encode!(variables)}"
    }
  end

  def authenticate(conn, login_params) do
    %{access_token: token} =
      login_params
      |> Authentication.login()
      |> elem(1)

    conn
    |> Plug.Conn.put_req_header("authorization", token)
  end

  def transform_struct(struct, fields \\ []) do
    struct
    |> Map.from_struct()
    |> Map.take(fields)
    |> Enum.map(fn {key, val} ->
      {Atom.to_string(key), val}
    end)
    |> Enum.into(%{})
  end

  def underscore_map_keys(schema_list) do
    schema_list
    |> Enum.map(fn map ->
      for {key, val} <- map, into: %{} do
        {Macro.underscore(key), val}
      end
    end)
  end
end

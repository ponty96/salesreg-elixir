defmodule SalesRegWeb.GraphqlTestHelpers do
  alias SalesRegWeb.Authentication

  def query_skeleton(:query, query_doc, query_name) do
    %{
      "operationName" => "#{query_name}",
      "query" => "query #{query_name}{#{query_doc}}",
      "variables" => "{}"
    }
  end

  def query_skeleton(:mutation, query_doc, query_name) do
    %{
      "operationName" => "#{query_name}",
      "query" => "mutation #{query_name}{#{query_doc}}",
      "variables" => "{}"
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
defmodule SalesRegWeb.GraphqlTestHelpers do
  alias SalesRegWeb.Authentication

  def query_skeleton(:query, query_doc, query_name) do
    %{
      "operationName" => "#{query_name}",
      "query" => "query #{query_name} #{query_doc}",
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
end

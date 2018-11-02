defmodule SalesReg.Test.GraphqlAccountsTest do
  use SalesReg.DataCase
  use Phoenix.ConnTest
  alias SalesRegWeb.Authentication
  alias SalesRegWeb.Test.Graphql.Helpers

  @endpoint MyApp.Web.Endpoint

  alias SalesReg.Accounts
  
  # describe "user schema tests" do
  #   @login_params %{
  #     email: "someemail@gmail.com",
  #     password: "asdfasdf"
  #   }

  #   test "login a user", context do
  #     query_doc = """
  #     {
  #       loginUser(
  #         email: "someemail@gmail.com",
  #         password: "asdfasdf"
  #       ){
  #         id,
  #         ... on Authorization {
  #           accessToken,
  #           refresh_token
  #         }
  #       }
  #     }
  #     """

  #     res = context.conn
  #       |> post("/graphiql", Helpers.query_skeleton(:mutation, query_doc, "loginUser"))

  #     IO.inspect json_response(res, 200)["data"], label: "json_response"

  #     ########################
  #     assert json_response(res, 200)["data"]["loginUser"]["id"] == to_string(note.id)
  #     ########################
  #   end
  # end
end

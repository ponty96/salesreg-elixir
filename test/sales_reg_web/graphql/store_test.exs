defmodule SalesRegWeb.GraphqlBusinessTest do
  use SalesRegWeb.ConnCase

  setup %{company: company, user: user} do
    categories = Enum.map(1..3, fn _index ->
      {:ok, category} = Seed.add_category(company.id, user.id)
      category.id
    end)

    service = user.id
    |> Seed.add_service(company.id, categories, [])

    %{service: service, categories: categories}
  end

  describe "service tests" do
    @tag :upsert_service 
    test "create a service", context do
      query_doc = """
        upsertService(
          service: {
            categories: #{context.categories},
            description: "description",
            name: "name",
            price: "100 Dollars",
            company_id: "#{context.company.id}",
            user_id: "#{context.user.id}",
            tags: [
              "#love",
              "#tbt",
              "#tgif",
              "#igers"
            ]
          }
        ){
          success,
          fieldErrors{
            key,
            message
          },
          data{
            ... on Service{
              id,
              description,
              name,
              price
            }
          }
        }
      """

      res =
        context.conn
        |> post("/graphiql", Helpers.query_skeleton(:mutation, query_doc, "upsertService"))

      response = json_response(res, 200)["data"]["upsertService"]

      assert response["data"]["description"] == "description"
      assert response["data"]["name"] == "name"
      assert response["data"]["price"] == "price"
      assert response["success"] == true
      assert response["fieldErrors"] == []
    end
  end
end

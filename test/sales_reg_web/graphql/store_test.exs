defmodule SalesRegWeb.GraphqlBusinessTest do
  use SalesRegWeb.ConnCase
  alias Faker.Company.En, as: CompanyEn

  setup %{company: company, user: user} do
    categories = Enum.map(1..3, fn _index ->
      {:ok, category} = Seed.add_category(company.id, user.id)
      category.id
    end)

    %{categories: categories}
  end

  def service_params(user_id, company_id, categories, tags) do
    %{
      "description" => "Our service is #{CompanyEn.bs()}",
      "name" => "#{CompanyEn.bs()} Service",
      "price" => "#{Enum.random([10_000, 50_000, 150_000])}",
      "user_id" => "#{user_id}",
      "company_id" => "#{company_id}",
      "categories" => categories,
      "tags" => tags
    }
  end

  describe "service tests" do
    @tag :create_service 
    test "create a service", %{
      company: company, 
      user: user,
      categories: categories,
      conn: conn
      } do
      query_doc = """
        mutation upsertService($service: ServiceInput!){
          upsertService(service: $service){
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
        }
      """

      variables = service_params(
          user.id, 
          company.id,
          categories, 
          ["#love", "#tbt", "#tgif", "#igers"]
        )

      res =
        conn
        |> post("/graphiql", Helpers.query_skeleton(query_doc, %{service: variables}))

      response = json_response(res, 200)["data"]["upsertService"]

      
      assert response["data"]["description"] == variables["description"]
      assert response["data"]["name"] == variables["name"]
      assert response["data"]["price"] == variables["price"]
      assert response["success"] == true
      assert response["fieldErrors"] == []
    end

    @tag :update_service 
    test "update a service", %{
      company: company, 
      user: user,
      categories: categories,
      conn: conn,
      } do
        {:ok, service} = user.id
        |> Seed.add_service(company.id, categories, [])
      
        query_doc = """
          mutation upsertService($service: ServiceInput!, $serviceId: ID!){
            upsertService(service: $service, serviceId: $serviceId){
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
          }
      """

      variables = service_params(
          user.id, 
          company.id,
          categories, 
          ["#love", "#tbt", "#tgif", "#igers"]
        )
  
      res =
        conn
        |> post("/graphiql", Helpers.query_skeleton(query_doc, %{service: variables, serviceId: "#{service.id}"}))

      response = json_response(res, 200)["data"]["upsertService"]
      
      assert response["data"]["description"] == variables["description"]
      assert response["data"]["name"] == variables["name"]
      assert response["data"]["price"] == variables["price"]
      assert response["success"] == true
      assert response["fieldErrors"] == []
    end

    @tag :query_all_company_services
    test "query all company services", %{
      company: company,
      conn: conn,
      user: user,
      categories: categories
    } do
      add_many_services =
        Enum.map(1..3, fn _index ->
          {:ok, service} =
            user.id
            |> Seed.add_service(
                company.id, 
                categories,
                ["#love", "#tbt", "#tgif", "#igers"]
              )

          service
          |> Helpers.transform_struct([
            :id,
            :description,
            :name,
            :price
          ])
        end)
        |> Enum.sort()

      query_doc = """
        query listCompanyServices($companyId: ID!){
          listCompanyServices(companyId: $companyId){
            id,
            description,
            name,
            price
          }
        }
      """
      variables = %{companyId: company.id}

      res =
        conn
        |> post("/graphiql", Helpers.query_skeleton(query_doc, variables))

      response =
        json_response(res, 200)["data"]["listCompanyServices"]
        |> Helpers.underscore_map_keys()
        |> Enum.sort()

      assert response == add_many_services
    end
  end
end

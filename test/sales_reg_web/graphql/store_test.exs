defmodule SalesRegWeb.GraphqlBusinessTest do
  use SalesRegWeb.ConnCase
  alias Faker.Company.En, as: CompanyEn
  alias Faker.Commerce

  setup %{company: company, user: user} do
    categories =
      Enum.map(1..3, fn _index ->
        {:ok, category} = Seed.add_category(company.id, user.id)
        category.id
      end)

    %{categories: categories}
  end

  def service_params(user_id, company_id, categories, tags) do
    %{
      "description" => "Our service is #{CompanyEn.bs()}",
      "name" => "engineering",
      "price" => "#{Enum.random([10_000, 50_000, 150_000])}",
      "user_id" => "#{user_id}",
      "company_id" => "#{company_id}",
      "categories" => categories,
      "tags" => tags,
      "featured_image" =>
        "https://snack-code-uploads.s3.us-west-1.amazonaws.com/~asset/9d799c33cbf767ffc1a72e53997218f7"
    }
  end

  def category_params(user_id, company_id) do
    %{
      "company_id" => company_id,
      "user_id" => user_id,
      "title" => "#{Commerce.department()}",
      "description" => "description"
    }
  end

  @user_params %{
    email: "randomemail@gmail.com",
    password: "asdf",
    password_confirmation: "asdf",
    first_name: "first name",
    last_name: "last name",
    gender: "MALE"
  }

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

      variables =
        service_params(
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
      conn: conn
    } do
      {:ok, service} =
        user.id
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

      variables =
        service_params(
          user.id,
          company.id,
          categories,
          ["#love", "#tbt", "#tgif", "#igers"]
        )

      res =
        conn
        |> post(
          "/graphiql",
          Helpers.query_skeleton(query_doc, %{service: variables, serviceId: "#{service.id}"})
        )

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

    @tag :search_services_by_name
    test "search services by name", %{
      user: user,
      company: company,
      categories: categories,
      conn: conn
    } do
      add_many_services =
        Enum.map(1..3, fn _index ->
          {:ok, service} =
            user.id
            |> service_params(
              company.id,
              categories,
              ["#love", "#tbt", "#tgif", "#igers"]
            )
            |> Store.add_service()

          service
          |> Helpers.transform_struct([
            :id,
            :name
          ])
        end)
        |> Enum.sort()

      query_doc = """
        query searchServicesByName($query: String!){
          searchServicesByName(query: $query){
            id,
            name
          }
        }
      """

      variables = %{query: "engineering"}

      res =
        conn
        |> post("/graphiql", Helpers.query_skeleton(query_doc, variables))

      response =
        json_response(res, 200)["data"]["searchServicesByName"]
        |> Helpers.underscore_map_keys()
        |> Enum.sort()

      assert response == add_many_services
    end
  end

  describe "category tests" do
    @tag :create_category
    test "create a category", %{
      company: company,
      user: user,
      conn: conn
    } do
      query_doc = """
          mutation upsertCategory($category: CategoryInput!){
            upsertCategory(category: $category){
              success,
              fieldErrors{
                key,
                message
              },
              data{
                ... on Category{
                  description,
                  title
                }
              }
            }
          }
      """

      variables = category_params(user.id, company.id)

      res =
        conn
        |> post("/graphiql", Helpers.query_skeleton(query_doc, %{category: variables}))

      response = json_response(res, 200)["data"]["upsertCategory"]

      assert response["data"]["description"] == variables["description"]
      assert response["data"]["title"] == variables["title"]
      assert response["success"] == true
      assert response["fieldErrors"] == []
    end

    @tag :update_category
    test "update a category", %{
      company: company,
      user: user,
      conn: conn
    } do
      {:ok, category} =
        company.id
        |> Seed.add_category(user.id)

      query_doc = """
          mutation upsertCategory($category: CategoryInput!, $categoryId: ID!){
            upsertCategory(category: $category, categoryId: $categoryId){
              success,
              fieldErrors{
                key,
                message
              },
              data{
                ... on Category{
                  description,
                  title
                }
              }
            }
          }
      """

      variables = category_params(user.id, company.id)

      res =
        conn
        |> post(
          "/graphiql",
          Helpers.query_skeleton(query_doc, %{category: variables, categoryId: "#{category.id}"})
        )

      response = json_response(res, 200)["data"]["upsertCategory"]

      assert response["data"]["description"] == variables["description"]
      assert response["data"]["title"] == variables["title"]
      assert response["success"] == true
      assert response["fieldErrors"] == []
    end

    @tag :query_all_company_categories
    test "query all company categories", %{
      conn: conn
    } do
      {:ok, user} = Accounts.create_user(@user_params)
      {:ok, company} = Seed.create_company(user.id)

      add_many_services =
        Enum.map(1..3, fn _index ->
          {:ok, category} =
            company.id
            |> Seed.add_category(user.id)

          category
          |> Helpers.transform_struct([
            :id,
            :title,
            :description
          ])
        end)
        |> Enum.sort()

      query_doc = """
        query listCompanyCategories($companyId: ID!){
          listCompanyCategories(companyId: $companyId){
            id,
            title,
            description
          }
        }
      """

      variables = %{companyId: company.id}

      res =
        conn
        |> post("/graphiql", Helpers.query_skeleton(query_doc, variables))

      response =
        json_response(res, 200)["data"]["listCompanyCategories"]
        |> Helpers.underscore_map_keys()
        |> Enum.sort()

      assert response == add_many_services
    end
  end
end

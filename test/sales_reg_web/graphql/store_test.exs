defmodule SalesRegWeb.GraphqlStoreTest do
  use SalesRegWeb.ConnCase
  alias Faker.Avatar
  alias Faker.Commerce
  alias Faker.Commerce.En, as: CommerceEn
  alias Faker.Company.En, as: CompanyEn
  alias SalesReg.Store

  setup %{company: company, user: user} do
    categories =
      Enum.map(1..3, fn _index ->
        {:ok, category} = Seed.add_category(company.id, user.id)
        category.id
      end)

    %{categories: categories}
  end

  @create_product_query """
    mutation createProduct($params: ProductInput!){
      createProduct(
      params: $params
    ){
        success,
        fieldErrors{
          key,
          message
        },
        data{
          ... on Product {
            id
            name
            minimum_sku
          }
        }
      }
    }
  """

  @update_product_query """
    mutation updateProduct($id: Uuid!, $params: ProductInput!){
      updateProduct(productId: $id, product: $params){
        success
        fieldErrors {
          key
          message
        }

        data {
          ... on Product {
            id
            name
            minimum_sku
          }
        }
      }
    }
  """

  @valid_product_params %{
    name: "Leather Shoe",
    sku: "30",
    minimum_sku: "10",
    price: "4000",
    featured_image: Avatar.image_url()
  }

  def valid_product_params(company, user) do
    @valid_product_params
    |> Map.put(:company_id, company.id)
    |> Map.put(:user_id, user.id)
  end

  def product_mutation_variables_without_variant(company, user) do
    %{
      product: valid_product_params(company, user),
      company_id: company.id
    }
  end

  def product_mutation_variables_with_variant(company, user) do
    product =
      company
      |> valid_product_params(user)

    %{
      product: product,
      company_id: company.id
    }
  end

  describe "product tests" do
    @tag :create_product_without_variant
    # test that user successfully creates a new product without variant
    test "create product without variant", %{company: company, user: user, conn: conn} do
      variables = %{params: product_mutation_variables_without_variant(company, user)}

      res =
        conn
        |> post("/graphiql", Helpers.query_skeleton(@create_product_query, variables))

      response = json_response(res, 200)["data"]["createProduct"]

      assert response["success"] == true
      assert response["data"]
      data = response["data"]
      assert @valid_product_params.name == data["name"]

      {:ok, company_products} = Store.list_company_products(company.id)
      assert length(company_products) == 1
    end

    # test for user editing a products details
    @tag :edit_product_details
    test "edit a product details", %{company: company, user: user, conn: conn} do
      variables = %{params: product_mutation_variables_without_variant(company, user)}

      res =
        conn
        |> post("/graphiql", Helpers.query_skeleton(@create_product_query, variables))

      response = json_response(res, 200)["data"]["createProduct"]

      assert response["success"] == true
      product = response["data"]
      assert product["minimum_sku"] == "10"

      edit_product_params =
        company
        |> valid_product_params(user)
        |> Map.update(:minimum_sku, "30", fn val -> "30" end)

      edit_product_variables = %{id: product["id"], params: edit_product_params}

      edit_product_res =
        conn
        |> post("/graphiql", Helpers.query_skeleton(@update_product_query, edit_product_variables))

      edit_product_res = json_response(edit_product_res, 200)["data"]["updateProduct"]

      assert edit_product_res["success"] == true
      assert product["id"] == edit_product_res["data"]["id"]
      refute product["minimum_sku"] == edit_product_res["data"]["minimum_sku"]
      assert edit_product_res["data"]["minimum_sku"] == "30"
    end
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

      add_many_categories =
        1..3
        |> Enum.map(fn _index ->
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

      response = json_response(res, 200)["data"]["listCompanyCategories"]

      response
      |> Helpers.underscore_map_keys()
      |> Enum.sort()

      assert response == add_many_categories
    end
  end
end

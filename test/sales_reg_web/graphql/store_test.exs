defmodule SalesRegWeb.GraphqlStoreTest do
  use SalesRegWeb.ConnCase
  alias SalesReg.{Store, Repo}
  alias Faker.Commerce.En, as: CommerceEn

  @valid_product_group_params %{
    product_group_title: "Leather Shoe"
  }

  @valid_product_params %{
    name: "Leather Shoe",
    sku: "30",
    minimum_sku: "10",
    selling_price: "4000"
  }

  def valid_product_params(company, user) do
    @valid_product_params
    |> Map.put(:company_id, company.id)
    |> Map.put(:user_id, user.id)
  end

  def valid_option_values(company_id) do
    options =
      company_id
      |> Store.list_company_options()
      |> elem(1)
      |> Enum.take(3)
      |> Enum.map(fn option ->
        %{
          option_id: option.id,
          name: CommerceEn.color(),
          company_id: company_id
        }
      end)

    options
  end

  def product_mutation_variables_without_variant(company, user) do
    %{
      product_group_title: "Leather Shoe",
      product: valid_product_params(company, user),
      company_id: company.id
    }
  end

  def product_mutation_variables_with_variant(company, user) do
    option_values = valid_option_values(company.id)

    product =
      company
      |> valid_product_params(user)
      |> Map.put(:option_values, option_values)

    %{
      product_group_title: "Leather Shoe",
      product: product,
      company_id: company.id
    }
  end

  describe "product tests" do
    # test for user successfully making a product a variant of an existing product(with variant)
    # test for user successfully making an existing product a variant
    # test for user editing a products details
    # test for user editing a product's options

    @tag :create_product_without_variant
    # test that user successfully creates a new product without variant
    test "create product without variant", %{company: company, user: user, conn: conn} do
      variables = %{params: product_mutation_variables_without_variant(company, user)}

      query = """
        mutation createProduct($params: ProductGroupInput!){
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
                productGroup {
                  id
                  title
                  options {
                    id
                    name
                  }
                }
                optionValues {
                  id
                  name
                  option {
                    id,
                    name
                  }
                }
              }
            }
          }
        }
      """

      res =
        conn
        |> post("/graphiql", Helpers.query_skeleton(query, variables))

      response = json_response(res, 200)["data"]["createProduct"]

      assert response["success"] == true
      assert response["data"]
      data = response["data"]
      assert @valid_product_params.name == data["name"]
      assert data["optionValues"] == []
      assert data["productGroup"]
      assert data["productGroup"]["options"] == []
    end

    @tag :create_product_with_variant
    # test that user successfully creates a new product with variant
    test "create product with variant", %{company: company, user: user, conn: conn} do
      variables = %{params: product_mutation_variables_with_variant(company, user)}

      query = """
        mutation createProduct($params: ProductGroupInput!){
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
                productGroup {
                  id
                  title
                  options {
                    id
                    name
                  }
                }
                optionValues {
                  id
                  name
                  option {
                    id,
                    name
                  }
                }
              }
            }
          }
        }
      """

      res =
        conn
        |> post("/graphiql", Helpers.query_skeleton(query, variables))

      response = json_response(res, 200)["data"]["createProduct"]

      assert response["success"] == true
      assert response["data"]
      data = response["data"]
      assert @valid_product_params.name == data["name"]
      refute data["optionValues"] == []
      assert data["productGroup"]
      refute data["productGroup"]["options"] == []
    end

    # test for user successfully making a product a variant of an existing product(with variant)
    @tag :add_variant_of_existing_product_with_variant
    test "add variant of existing product with variant", %{
      company: company,
      user: user,
      conn: conn
    } do
      # create product with variant first

      variables = %{params: product_mutation_variables_with_variant(company, user)}

      query = """
        mutation createProduct($params: ProductGroupInput!){
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
                productGroup {
                  id
                  title
                  options {
                    id
                    name
                  }

                  products {
                    optionValues {
                      name
                      option {
                        name
                      }
                    }
                  }
                }
                optionValues {
                  id
                  name
                  option {
                    id,
                    name
                  }
                }
              }
            }
          }
        }
      """

      res =
        conn
        |> post("/graphiql", Helpers.query_skeleton(query, variables))

      response = json_response(res, 200)["data"]["createProduct"]

      assert response["success"] == true
      assert response["data"]
      data = response["data"]
      assert @valid_product_params.name == data["name"]
      refute data["optionValues"] == []
      assert data["productGroup"]
      refute data["productGroup"]["options"] == []

      add_variant_variables = %{
        params:
          product_mutation_variables_with_variant(company, user)
          |> Map.put(:product_group_id, data["productGroup"]["id"])
      }

      add_variant_res =
        conn
        |> post("/graphiql", Helpers.query_skeleton(query, add_variant_variables))

      add_variant_response = json_response(add_variant_res, 200)["data"]["createProduct"]

      assert add_variant_response["success"] == true
      assert add_variant_response["data"]

      add_variant_data = add_variant_response["data"]

      assert add_variant_data["productGroup"]["id"] == data["productGroup"]["id"]
      assert add_variant_data["productGroup"]["options"] == data["productGroup"]["options"]
      refute add_variant_data["id"] == data["id"]
    end
  end
end

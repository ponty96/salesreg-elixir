defmodule SalesRegWeb.GraphqlStoreTest do
  use SalesRegWeb.ConnCase
  alias SalesReg.Store
  alias Faker.Commerce.En, as: CommerceEn

  @create_product_query """
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
            minimum_sku
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
      assert data["optionValues"] == []
      assert data["productGroup"]
      assert data["productGroup"]["options"] == []

      {:ok, company_products} = Store.list_company_products(company.id)
      assert length(company_products) == 1
    end

    @tag :create_product_with_variant
    # test that user successfully creates a new product with variant
    test "create product with variant", %{company: company, user: user, conn: conn} do
      variables = %{params: product_mutation_variables_with_variant(company, user)}

      res =
        conn
        |> post("/graphiql", Helpers.query_skeleton(@create_product_query, variables))

      response = json_response(res, 200)["data"]["createProduct"]

      assert response["success"] == true
      assert response["data"]
      data = response["data"]
      assert @valid_product_params.name == data["name"]
      refute data["optionValues"] == []
      assert data["productGroup"]
      refute data["productGroup"]["options"] == []

      {:ok, company_products} = Store.list_company_products(company.id)
      assert length(company_products) == 1
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

      res =
        conn
        |> post("/graphiql", Helpers.query_skeleton(@create_product_query, variables))

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
        |> post("/graphiql", Helpers.query_skeleton(@create_product_query, add_variant_variables))

      add_variant_response = json_response(add_variant_res, 200)["data"]["createProduct"]

      assert add_variant_response["success"] == true
      assert add_variant_response["data"]

      add_variant_data = add_variant_response["data"]

      assert add_variant_data["productGroup"]["id"] == data["productGroup"]["id"]
      assert add_variant_data["productGroup"]["options"] == data["productGroup"]["options"]
      refute add_variant_data["id"] == data["id"]

      {:ok, company_products} = Store.list_company_products(company.id)
      assert length(company_products) == 2
    end
  end

  # test for user successfully making an existing product a variant
  @tag :make_an_existing_product_a_variant
  test "make an existing product a variant", %{company: company, user: user, conn: conn} do
    variables = %{params: product_mutation_variables_without_variant(company, user)}

    res =
      conn
      |> post("/graphiql", Helpers.query_skeleton(@create_product_query, variables))

    response = json_response(res, 200)["data"]["createProduct"]

    assert response["success"] == true
    assert response["data"]
    data = response["data"]
    assert @valid_product_params.name == data["name"]
    assert data["optionValues"] == []
    assert data["productGroup"]
    assert data["productGroup"]["options"] == []

    add_variant_variables = %{
      params:
        product_mutation_variables_with_variant(company, user)
        |> Map.put(:product_group_id, data["productGroup"]["id"])
        |> Map.update(:product, %{}, fn product ->
          Map.put(product, :id, response["data"]["id"])
        end)
    }

    add_variant_res =
      conn
      |> post("/graphiql", Helpers.query_skeleton(@create_product_query, add_variant_variables))

    add_variant_response = json_response(add_variant_res, 200)["data"]["createProduct"]

    assert add_variant_response["success"] == true
    assert add_variant_response["data"]

    add_variant_data = add_variant_response["data"]

    assert add_variant_data["productGroup"]["id"] == data["productGroup"]["id"]
    refute add_variant_data["productGroup"]["options"] == data["productGroup"]["options"]
    assert add_variant_data["id"] == data["id"]
    refute add_variant_data["optionValues"] == []
    assert add_variant_data["productGroup"]
    refute add_variant_data["productGroup"]["options"] == []

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

  # test for user editing a product's options
  @tag :edit_product_options
  test "test that user can successfully change a product's options", %{
    company: company,
    user: user,
    conn: conn
  } do
    variables = %{params: product_mutation_variables_with_variant(company, user)}

    res =
      conn
      |> post("/graphiql", Helpers.query_skeleton(@create_product_query, variables))

    response = json_response(res, 200)["data"]["createProduct"]

    assert response["success"] == true
    assert response["data"]
    data = response["data"]
    assert @valid_product_params.name == data["name"]
    refute data["optionValues"] == []
    assert data["productGroup"]
    refute data["productGroup"]["options"] == []

    product_options = data["productGroup"]["options"]

    {:ok, company_products} = Store.list_company_products(company.id)
    assert length(company_products) == 1

    edit_product_options_query = """
      mutation updateProductGroupOptions($id: Uuid!, $options: [Uuid]!){
        updateProductGroupOptions(id: $id, options: $options){
          success
          data {
            ... on ProductGroup {
              id
              title
              options {
                id
                name
                optionValues {
                  name
                  option {
                    name
                  }
                }
              }
            }
          }
        }
      }
    """

    options =
      Store.list_company_options(company.id)
      |> elem(1)
      |> Enum.take_random(4)
      |> Enum.map(& &1.id)

    edit_product_options_variables = %{
      id: data["productGroup"]["id"],
      options: options
    }

    edit_product_options_res =
      conn
      |> post(
        "/graphiql",
        Helpers.query_skeleton(edit_product_options_query, edit_product_options_variables)
      )

    edit_product_options_response =
      json_response(edit_product_options_res, 200)["data"]["updateProductGroupOptions"]

    edit_product_options_response["success"] == true

    refute edit_product_options_response["data"]["options"] == product_options
  end
end

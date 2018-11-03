defmodule SalesRegWeb.GraphqlBusinessTest do
  use SalesReg.DataCase
  use Phoenix.ConnTest
  alias SalesRegWeb.GraphqlTestHelpers, as: Helpers
  alias SalesReg.{Business, Accounts}

  @endpoint SalesRegWeb.Endpoint
  
  @user_params %{
    date_of_birth: "20-11-1999",
    email: "someemail@gmail.com",
    first_name: "firstname",
    gender: "Male",
    last_name: "lastname",
    password: "asdfasdf",
    password_confirmation: "asdfasdf",
    profile_picture: "picture.jpg"
  }

  @company_params %{
    title: "this is the title",
    contact_email: "someemail@gmail.com",
    currency: "Euro",
    phone: %{
      number: "+2348131900893"
    }
  }

  setup do
    {:ok, user} = Accounts.create_user(@user_params)
    login_params = %{email: user.email, password: user.password}
    conn = Helpers.authenticate(build_conn(), login_params)

    {:ok, company} = user.id
    |> Business.create_company(@company_params)
    
    %{user: user, conn: conn, company: company}
  end
  
  describe "company tests" do
    # adds a user to a company
    @tag :add_user_company
    test "add user company", context do
      {:ok, user} = @user_params
        |> Map.put(:email, "randomemail@gmail.com")
        |> Accounts.create_user()
      
      query_doc = """
        addUserCompany(
          user: "#{user.id}",
          company: {
            title: "company title",
            contact_email: "someemail@gmail.com",
            currency: "Dollars",
            head_office: {
              city: "Akure",
              country: "Nigeria",
              state: "Ondo",
              street1: "Roadblock",
            }, 
          }
        ){
            success,
            fieldErrors{
              key,
              message
            },
            data{
              ... on Company{
                id,
                title,
                contact_email,
                currency
              }
            }
          }
      """

      res = context.conn
        |> post("/graphiql", Helpers.query_skeleton(:mutation, query_doc, "addUserCompany"))

      response = json_response(res, 200)["data"]["addUserCompany"] 
      
      assert response["data"]["title"] == "company title"
      assert response["data"]["contact_email"] == "someemail@gmail.com"
      assert response["data"]["currency"] == "Dollars"
      assert response["success"] == true
      assert response["fieldErrors"] == []
    end

    @tag :update_company
    # # updates company
    test "update company", context do
      query_doc = """
        updateCompany(
          id: "#{context.company.id}",
          company: {
            title: "updated title",
            contact_email: "updatedemail@gmail.com",
            currency: "Dollars",
            head_office: {
              city: "Akure",
              country: "Nigeria",
              state: "Ondo",
              street1: "Roadblock",
            },
          }
        ){
          success,
          fieldErrors{
            key,
            message
          },
          data{
            ... on Company{
              id,
              title,
              contact_email,
              currency
            }
          }
        }
      """

      res = context.conn
      |> post("/graphiql", Helpers.query_skeleton(:mutation, query_doc, "updateCompany"))

      response = json_response(res, 200)["data"]["updateCompany"] 
      company_id = context.company.id

      assert response["data"]["id"] == company_id
      assert response["data"]["title"] == "updated title"
      assert response["data"]["contact_email"] == "updatedemail@gmail.com"
      assert response["data"]["currency"] == "Dollars"
      assert response["success"] == true
      assert response["fieldErrors"] == []
    end
  end
end

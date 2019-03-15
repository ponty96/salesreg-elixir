defmodule SalesRegWeb.GraphqlBusinessTest do
  use SalesRegWeb.ConnCase

  @user_params %{
    date_of_birth: "20-11-1999",
    email: "randomemail@gmail.com",
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
    },
    slug: "sanbox",
    head_office: %{
      street1: "J11 Obaile housing estate",
      city: "Akure",
      state: "Ondo",
      country: "NGN"
    }
  }

  @bank_params %{
    account_name: "Account Name",
    account_number: "0101010101",
    bank_name: "Bank Name",
    bank_code: "Bank Code"
  }

  @expense_params %{
    date: "10-9-2018",
    expense_items: [
      %{
        item_name: "Samsung",
        amount: "20.007"
      }
    ],
    payment_method: "CASH",
    title: "expense title",
    total_amount: "20.007"
  }

  @legal_document_params %{
    name: "Refund Policy",
    type: "POLICY",
    content: "This is the refund policy"
  }

  def add_user_company_variables(user) do
    %{
      user: user.id,
      company: @company_params
    }
  end

  describe "company tests" do
    # adds a user to a company
    @tag company: "add_user_company"
    test "add user company", context do
      query_doc = """
        mutation addUserCompany($user: Uuid!, $company: CompanyInput!){
          addUserCompany(
            user: $user,
            company: $company
          ){
            success,
            fieldErrors{
              key,
              message
            }
          }
        }
      """

      res =
        context.conn
        |> post("/graphiql", Helpers.query_skeleton(query_doc, add_user_company_variables(context.user)))

      response = json_response(res, 200)["data"]["addUserCompany"]

      assert response["success"] == true
      assert response["fieldErrors"] == []
      assert length(Business.all_company()) == 1
    end

    # updates company
    @tag company: "update_company"
    test "update company", context do
      {:ok, company} =
        context.user.id
        |> Business.create_company(@company_params)
      
      query_doc = """
        mutation updateCompany($id: Uuid!, $company: CompanyInput!){
          updateCompany(
            id: $id,
            company: $company
          ){
            success,
            fieldErrors{
              key,
              message
            },
            data{
              ... on Company{
                id
              }
            }
          }
        }
      """
      variables = %{id: company.id, company: @company_params}
      res =
        context.conn
        |> post("/graphiql", Helpers.query_skeleton(query_doc, variables))

      response = json_response(res, 200)["data"]["updateCompany"]

      assert response["success"] == true
      assert response["fieldErrors"] == []
      assert length(Business.all_company()) == 1
      assert company.id == response["data"]["id"]
    end

    # updates company's cover photo
    @tag company: "update_company_cover_photo"
    test "update company cover photo", context do
      {:ok, company} =
        context.user.id
        |> Business.create_company(@company_params)
      
      query_doc = """
        mutation updateCompanyCoverPhoto($coverPhoto: CoverPhotoInput!){
          updateCompanyCoverPhoto(
            coverPhoto: $coverPhoto
          ){
            fieldErrors{
              key,
              message
            },
            success,
            data {
              ... on Company{
                coverPhoto
              }
            }
          }
        }
      """

      variables = %{coverPhoto: %{coverPhoto: "img1234", companyId: company.id}}
      res =
        context.conn
        |> post("/graphiql", Helpers.query_skeleton(query_doc, variables))

      response = json_response(res, 200)["data"]["updateCompanyCoverPhoto"]

      assert response["success"] == true
      assert response["fieldErrors"] == []
      assert is_nil(response["data"]["coverPhoto"]) == false
    end
  end

  describe "Bank tests" do
    # Create a Bank
    @tag bank: "create_bank"
    test "create a bank", context do
      {:ok, company} =
        context.user.id
        |> Business.create_company(@company_params)

      query_doc = """
        mutation upsertBank($bank: BankInput!){
          upsertBank(
            bank: $bank
          ){
            fieldErrors {
              key,
              message
            },
            success
          }
        }
      """
      variables = %{bank: Map.put_new(@bank_params, :company_id, company.id)}

      res =
        context.conn
        |> post("/graphiql", Helpers.query_skeleton(query_doc, variables))
      
      response = json_response(res, 200)["data"]["upsertBank"]

      assert response["success"] == true
      assert response["fieldErrors"] == []
      assert length(Business.all_bank()) == 1
    end

    # Update a Bank
    @tag bank: "update_bank"
    test "update a bank", context do
      {:ok, company} =
        context.user.id
        |> Business.create_company(@company_params)

      {:ok, bank} =
        @bank_params
        |> Map.put_new(:company_id, company.id)
        |> Business.create_bank()

      query_doc = """
        mutation upsertBank($bankId: Uuid!, $bank: BankInput!){
          upsertBank(
            bank: $bank,
            bankId: $bankId
          ){
            fieldErrors {
              key,
              message
            },
            success,
            data {
              ...on Bank{
                id
              }
            }
          }
        }
      """
      
      variables = %{bankId: bank.id, bank: Map.put_new(@bank_params, :company_id, company.id)}
      res =
        context.conn
        |> post("/graphiql", Helpers.query_skeleton(query_doc, variables))

      response = json_response(res, 200)["data"]["upsertBank"]

      assert response["success"] == true
      assert response["fieldErrors"] == []
      assert response["data"]["id"] == bank.id
    end

    # Delete a Bank
    @tag bank: "delete_bank"
    test "delete a bank", context do
      {:ok, company} =
        context.user.id
        |> Business.create_company(@company_params)

      {:ok, bank} =
        @bank_params
        |> Map.put_new(:company_id, company.id)
        |> Business.create_bank()

      query_doc = """
        mutation deleteBank($bankId: Uuid!){
          deleteBank(
            bankId: $bankId
          ){
            success,
            fieldErrors{
              key,
              message
            }
          }
        }
      """

      res =
        context.conn
        |> post("/graphiql", Helpers.query_skeleton(query_doc, %{bankId: bank.id}))

      response = json_response(res, 200)["data"]["deleteBank"]

      assert response["success"] == true
      assert response["fieldErrors"] == []
      assert length(Business.all_bank) == 0
      assert Business.get_bank(bank.id) == nil
    end

    @tag bank: "query_all_company_banks"
    test "query all company banks", context do
      {:ok, company} =
        context.user.id
        |> Business.create_company(@company_params)

      add_many_banks =
        Enum.map(1..3, fn _index ->
          @bank_params
          |> Map.put_new(:company_id, company.id)
          |> Business.create_bank()
        end)

      query_doc = """
        query companyBanks($companyId: Uuid!, $first: Int){
          companyBanks(
            companyId: $companyId,
            first: $first
          ){
            edges{
              node{
                company{
                  id
                }
              }
            }
          }
        }
      """

      variables = %{companyId: company.id, first: 5}
      res =
        context.conn
        |> post("/graphiql", Helpers.query_skeleton(query_doc, variables))
      
      response = json_response(res, 200)["data"]["companyBanks"]["edges"]

      assert length(response) == 3
      assert Enum.all?(response, &(&1["node"]["company"]["id"] == company.id))
    end
  end

  describe "Expense tests" do
    @tag expense: "create_expense"
    test "create an expense", context do
      {:ok, company} =
        context.user.id
        |> Business.create_company(@company_params)

      query_doc = """
        mutation upsertExpense($expense: ExpenseInput!){
          upsertExpense(expense: $expense){
            success,
            fieldErrors{
              key,
              message
            },
            data {
              ... on Expense{
                id,
                paymentMethod,
                title,
                totalAmount,
                date
              }
            }
          }
        }
      """

      variables = %{expense: 
        Map.put_new(@expense_params, :company_id, company.id)
        |> Map.put_new(:paid_by_id, context.user.id)
      }
      res =
        context.conn
        |> post("/graphiql", Helpers.query_skeleton(query_doc, variables))

      response = json_response(res, 200)["data"]["upsertExpense"]

      assert response["success"] == true
      assert response["fieldErrors"] == []
      assert length(Business.all_expense()) == 1
    end

    @tag expense: "update_expense"
    test "update expense", context do
      {:ok, company} =
        context.user.id
        |> Business.create_company(@company_params)

      {:ok, expense} =
        @expense_params
        |> Map.put_new(:company_id, company.id)
        |> Map.put_new(:paid_by_id, context.user.id)
        |> Business.create_expense()

      query_doc = """
        mutation upsertExpense($expense: ExpenseInput!, $expenseId: Uuid){
          upsertExpense(
            expense: $expense,
            expenseId: $expenseId
          ){
            success,
            fieldErrors{
              key,
              message
            },
            data {
              ... on Expense{
                id,
                paymentMethod,
                title,
                totalAmount,
                date
              }
            }
          }
        }
      """
      variables = %{expense: 
        Map.put_new(@expense_params, :company_id, company.id)
        |> Map.put_new(:paid_by_id, context.user.id),

        expenseId: expense.id
      }

      res =
        context.conn
        |> post("/graphiql", Helpers.query_skeleton(query_doc, variables))

      response = json_response(res, 200)["data"]["upsertExpense"]

      assert response["success"] == true
      assert response["fieldErrors"] == []
      assert length(Business.all_expense()) == 1
      assert expense.id == response["data"]["id"]
    end

    @tag expense: "query_all_company_expenses"
    test "query all company expenses", context do
      {:ok, company} =
        context.user.id
        |> Business.create_company(@company_params)

      add_many_expenses =
        Enum.map(1..3, fn _index ->
          @expense_params
          |> Map.put_new(:company_id, company.id)
          |> Map.put_new(:paid_by_id, context.user.id)
          |> Business.create_expense()
        end)

      query_doc = """
        query companyExpenses($companyId: Uuid!, $first: Int, $query: String!){
          companyExpenses(
            companyId: $companyId,
            first: $first,
            query: $query
          ){
            edges{
              node{
                company{
                  id
                }
              }
            }
          }
        }
      """

      variables = %{companyId: company.id, first: 5, query: ""}
      res =
        context.conn
        |> post("/graphiql", Helpers.query_skeleton(query_doc, variables))

      response = json_response(res, 200)["data"]["companyExpenses"]["edges"]

      assert length(response) == 3
      assert Enum.all?(response, &(&1["node"]["company"]["id"] == company.id))
    end
  end

  describe "legal_document tests" do
    # Upsert a legal_document
    @tag legal_document: "create_legal_document"
    test "create a legal_document", context do
      {:ok, company} =
        context.user.id
        |> Business.create_company(@company_params)

      query_doc = """
        mutation upsertLegalDocument($legalDocument: LegalDocumentInput!){
          upsertLegalDocument(legalDocument: $legalDocument){
            success,
            fieldErrors{
              key,
              message
            }
          }
        }
      """
      variables = %{legalDocument: Map.put_new(@legal_document_params, :company_id, company.id)}
      res =
        context.conn
        |> post("/graphiql", Helpers.query_skeleton(query_doc, variables))
        
      response = json_response(res, 200)["data"]["upsertLegalDocument"]

      assert response["success"] == true
      assert response["fieldErrors"] == []
    end

    @tag legal_document: "update_legal_document"
    test "update a legal_document", context do
      {:ok, legal_document} =
        @legal_document_params
        |> Map.put_new(:company_id, context.company.id)
        |> Business.add_legal_document()

      query_doc = """
      upsertLegalDocument(
        legalDocument: {
          name: "Updated Refund policy",
          type: POLICY,
          content: "This is the updated refund policy",
          companyId: "#{context.company.id}"
        }, legalDocumentId: "#{legal_document.id}"){
          fieldErrors {
            key,
            message
          },
          success,
          data {
            ... on Company{
              id
            }
          }
        }
      """

      res =
        context.conn
        |> post("/graphiql", Helpers.query_skeleton(:mutation, query_doc, "upsertLegalDocument"))

      response = json_response(res, 200)["data"]["upsertLegalDocument"]

      assert response["success"] == true
      assert response["fieldErrors"] == []
    end

    @tag legal_document: "delete_legal_document"
    test "delete a legal_document", context do
      {:ok, legal_document} =
        @legal_document_params
        |> Map.put_new(:company_id, context.company.id)
        |> Business.add_legal_document()

      query_doc = """
      deleteLegalDocument(
        legalDocumentId: "#{legal_document.id}"
        ){
        success,
        fieldErrors{
          key,
          message
          }
        data {
          ... on Company{
            id
          }
        }
        }
      """

      res =
        context.conn
        |> post("/graphiql", Helpers.query_skeleton(:mutation, query_doc, "deleteLegalDocument"))

      response = json_response(res, 200)["data"]["deleteLegalDocument"]

      assert response["success"] == true
      assert response["fieldErrors"] == []
    end
  end
end

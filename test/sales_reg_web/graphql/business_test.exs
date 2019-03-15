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
    type: "policy",
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
                id,
                isPrimary,
                accountName,
                accountNumber,
                bankName,
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

    @tag :update_expense
    test "update expense", context do
      {:ok, expense} =
        @expense_params
        |> Map.put_new(:company_id, context.company.id)
        |> Map.put_new(:paid_by_id, context.user.id)
        |> Business.add_expense()

      query_doc = """
      upsertExpense(
        expense: {
          companyId: "#{context.company.id}",
          date: "11-9-2018",
          expenseItems: [
            {
              amount: 20.007,
              itemName: "Samsung"
            },
            {
              amount: 30.0884,
              itemName: "Dell"
            }
          ],
          paidById: "#{context.user.id}",
          paymentMethod: CARD,
          title: "update expense title",
          totalAmount: 50.0954
        }, expenseId: "#{expense.id}"
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
      """

      res =
        context.conn
        |> post("/graphiql", Helpers.query_skeleton(:mutation, query_doc, "upsertExpense"))

      response = json_response(res, 200)["data"]["upsertExpense"]

      assert response["data"]["id"] == expense.id
      assert response["data"]["date"] == "11-9-2018"
      assert response["data"]["paymentMethod"] == "card"
      assert response["data"]["title"] == "update expense title"
      assert response["data"]["totalAmount"] == "50.0954"
      assert response["success"] == true
      assert response["fieldErrors"] == []
    end

    @tag :query_all_company_expenses
    test "query all company expenses", context do
      add_many_expenses =
        Enum.map(1..3, fn _index ->
          {:ok, expense} =
            context.user.id
            |> Seed.add_expense(context.company.id)

          expense
          |> Helpers.transform_struct([
            :id,
            :title,
            :date,
            :total_amount,
            :payment_method
          ])
        end)
        |> Enum.map(fn expense ->
          total_amount =
            expense["total_amount"]
            |> Decimal.to_float()
            |> Float.round(2)

          %{expense | "total_amount" => total_amount}
        end)
        |> Enum.sort()

      query_doc = """
      companyExpenses(
        companyId: "#{context.company.id}"
      ){
        id,
        title,
        date,
        totalAmount,
        paymentMethod
      }
      """

      res =
        context.conn
        |> post("/graphiql", Helpers.query_skeleton(:query, query_doc, "companyExpenses"))

      response =
        json_response(res, 200)["data"]["companyExpenses"]
        |> Helpers.underscore_map_keys()
        |> Enum.map(fn map ->
          total_amount =
            map["total_amount"]
            |> String.to_float()
            |> Float.round(2)

          %{map | "total_amount" => total_amount}
        end)
        |> Enum.sort()

      assert response == add_many_expenses
    end
  end

  describe "Tag test" do
    @tag :query_all_company_tags
    test "query all company tags", context do
      add_many_tags =
        Enum.map(["#tbt", "#tgif"], fn hashtag ->
          {:ok, tag} = Seed.add_tag(context.company.id, hashtag)

          tag
          |> Helpers.transform_struct([:id, :name])
        end)
        |> Enum.sort()

      query_doc = """
      companyTags(
        companyId: "#{context.company.id}",
      ){
        id,
        name
      }
      """

      res =
        context.conn
        |> post("/graphiql", Helpers.query_skeleton(:query, query_doc, "companyTags"))

      response =
        json_response(res, 200)["data"]["companyTags"]
        |> Enum.sort()

      assert response == add_many_tags
    end
  end

  describe "legal_document tests" do
    # Upsert a legal_document
    @tag legal_document: "create_legal_document"
    test "create a legal_document", context do
      query_doc = """
      upsertLegalDocument(
        legalDocument: {
          name: "Refund policy",
          type: POLICY,
          content: "This is the refund policy",
          companyId: "#{context.company.id}"
        }){
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

      IO.inspect(res.resp_body, label: "response body")
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

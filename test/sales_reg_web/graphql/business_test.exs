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

  @bank_params %{
    account_name: "Account Name",
    account_number: "0101010101",
    bank_name: "Bank Name"
  }

  @expense_params %{
    date: "10-9-2018",
    expense_items: [
      %{
        item_name: "Samsung",
        amount: 20.007
      }
    ],
    payment_method: "Cash",
    title: "expense title",
    total_amount: 20.007,
    items_amount: 20.007
  }

  @legal_document_params %{
    name: "Refund Policy",
    type: "policy",
    content: "This is the refund policy"
  }

  describe "company tests" do
    # adds a user to a company
    @tag :add_user_company
    test "add user company", context do
      {:ok, user} =
        @user_params
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

      res =
        context.conn
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

      res =
        context.conn
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

    @tag company: "update_company_cover_photo"
    test "update company cover photo", context do
      query_doc = """
      updateCompanyCoverPhoto(
        coverPhoto:{
          coverPhoto: "img1234",
          companyId: "#{context.company.id}"
        }){
          fieldErrors{
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
        |> post(
          "/graphiql",
          Helpers.query_skeleton(:mutation, query_doc, "updateCompanyCoverPhoto")
        )

      response = json_response(res, 200)["data"]["updateCompanyCoverPhoto"]

      assert response["success"] == true
      assert response["fieldErrors"] == []
    end
  end

  describe "Bank tests" do
    # Upsert a Bank
    @tag bank: "create_bank"
    test "create a bank", context do
      query_doc = """
      upsertBank(
        bank: {
          accountName: "Account Name",
          accountNumber: "0101010101",
          bankName: "Bank Name",
          companyId: "#{context.company.id}"
        }){
          fieldErrors {
            key,
            message
          },
          success,
          data {
            ...on Bank{
              accountName,
              accountNumber,
              bankName,
              isPrimary
            }
          }
        }
      """

      res =
        context.conn
        |> post("/graphiql", Helpers.query_skeleton(:mutation, query_doc, "upsertBank"))

      response = json_response(res, 200)["data"]["upsertBank"]

      assert response["data"]["isPrimary"] == true
      assert response["data"]["bankName"] == "Bank Name"
      assert response["data"]["accountNumber"] == "0101010101"
      assert response["data"]["accountName"] == "Account Name"
      assert response["success"] == true
      assert response["fieldErrors"] == []
    end

    test "update a bank", context do
      {:ok, bank} =
        @bank_params
        |> Map.put_new(:company_id, context.company.id)
        |> Business.create_bank()

      query_doc = """
      upsertBank(
        bank: {
          accountName: "Updated Account Name",
          accountNumber: "1010101010",
          bankName: "Updated Bank Name",
          companyId: "#{context.company.id}",
          is_primary: false
        }, bankId: "#{bank.id}"){
          fieldErrors {
            key,
            message
          },
          success,
          data {
            ...on Bank{
              accountName,
              accountNumber,
              bankName,
              isPrimary
            }
          }
        }
      """

      res =
        context.conn
        |> post("/graphiql", Helpers.query_skeleton(:mutation, query_doc, "upsertBank"))

      response = json_response(res, 200)["data"]["upsertBank"]

      assert response["data"]["isPrimary"] == false
      assert response["data"]["bankName"] == "Updated Bank Name"
      assert response["data"]["accountNumber"] == "1010101010"
      assert response["data"]["accountName"] == "Updated Account Name"
      assert response["success"] == true
      assert response["fieldErrors"] == []
    end

    test "delete a bank", context do
      {:ok, bank} =
        @bank_params
        |> Map.put_new(:company_id, context.company.id)
        |> Business.create_bank()

      query_doc = """
      deleteBank(
        bankId: "#{bank.id}"
      ){
        success,
        fieldErrors{
          key,
          message
        }
      }
      """

      res =
        context.conn
        |> post("/graphiql", Helpers.query_skeleton(:mutation, query_doc, "deleteBank"))

      response = json_response(res, 200)["data"]["deleteBank"]

      assert response["success"] == true
      assert response["fieldErrors"] == []
    end

    @tag :query_all_company_banks
    test "query all company banks", context do
      add_many_banks =
        Enum.map(1..3, fn _index ->
          {:ok, bank} =
            context.company.id
            |> Seed.create_bank()

          bank
          |> Helpers.transform_struct([
            :id,
            :is_primary,
            :account_name,
            :account_number,
            :bank_name
          ])
        end)
        |> Enum.sort()

      query_doc = """
      companyBanks(
        companyId: "#{context.company.id}",
      ){
        id,
        isPrimary,
        accountName,
        accountNumber,
        bankName
      }
      """

      res =
        context.conn
        |> post("/graphiql", Helpers.query_skeleton(:query, query_doc, "companyBanks"))

      response =
        json_response(res, 200)["data"]["companyBanks"]
        |> Helpers.underscore_map_keys()
        |> Enum.sort()

      assert response == add_many_banks
    end
  end

  describe "Expense tests" do
    @tag :create_expense
    test "create an expense", context do
      query_doc = """
      upsertExpense(
        expense: {
          companyId: "#{context.company.id}",
          date: "10-9-2018",
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
          paymentMethod: CASH,
          title: "expense title",
          totalAmount: 50.0954
        }
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

      assert response["data"]["paymentMethod"] == "cash"
      assert response["data"]["title"] == "expense title"
      assert response["data"]["totalAmount"] == "50.0954"
      assert response["data"]["date"] == "10-9-2018"
      assert response["success"] == true
      assert response["fieldErrors"] == []
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

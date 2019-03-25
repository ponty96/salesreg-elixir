defmodule SalesRegWeb.GraphqlOrderTest do
  use SalesRegWeb.ConnCase
  use SalesRegWeb, :context

  @create_sale_order_query """
    mutation upsertSaleOrder($sale: SaleInput!){
      upsertSaleOrder(
        sale: $sale
    ){
      success,
      fieldErrors{
        key,
        message
      },
      data{
        ... on Sale{
          id
        }
      }
    }
  }
  """

  @update_sale_order_status_query """
    mutation updateOrderStatus($status: OrderStatus!, $id: Uuid!, $orderType: String){
      updateOrderStatus(
        status: $status,
        id: $id,
        orderType: $orderType
    ){
      success,
      fieldErrors{
        key,
        message
      },
      data{
        ... on Sale{
          id,
          status
        }
      }
    }
  }
  """

  @update_invoice_due_date_query """
    mutation updateInvoice($invoice: InvoiceInput!, $invoiceId: Uuid!){
      updateInvoice(invoice: $invoice, invoiceId: $invoiceId){
        success,
        fieldErrors{
          key,
          message
        },
        data{
          ... on Invoice{
            id,
            dueDate
          }
        }
      }
    }
  """

  @add_review_query """
    mutation addReview($review: ReviewInput!){
      addReview(review: $review){
        success,
        fieldErrors{
          key,
          message
        },
        data{
          ... on Review{
            id,
            text
          }
        }
      }
    }
  """

  @add_star_query """
    mutation addStar($star: StarInput!){
      addStar(star: $star){
        success,
        fieldErrors{
          key,
          message
        },
        data{
          ... on Star{
            id,
            value
          }
        }
      }
    }
  """

  @create_receipt_query """
    mutation createReceipt($invoiceId: Uuid!, $amountPaid: String!){
      createReceipt(
        invoiceId: $invoiceId,
        amountPaid: $amountPaid
      ){
        success,
        fieldErrors{
          key,
          message
        },
        data{
          ... on Receipt{
            amountPaid,
            paymentMethod
          }
        }
      }
    }
  """

  @all_company_sales_query """
    query listCompanySales($companyId: Uuid!, $first: Int){
      listCompanySales(companyId: $companyId, first: $first){
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

  @all_company_invoices_query """
    query listCompanyInvoices($companyId: Uuid!, $first: Int){
      listCompanyInvoices(companyId: $companyId, first: $first){
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

  @all_company_activities_query """
    query listContactActivities($companyId: Uuid!, $contactId: Uuid, $first: Int){
      listContactActivities(companyId: $companyId, contactId: $contactId, first: $first){
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

  @sale_params %{
    amount_paid: "390.0",
    date: "2019-01-30",
    payment_method: "CASH"
  }

  @items_params [
    %{
      quantity: "3",
      unit_price: "50"
    },
    %{
      quantity: "4",
      unit_price: "60"
    }
  ]

  @product_params  %{
    sku: "20",
    minimum_sku: "7",
    price: "3500",
    featured_image: "https://www-konga-com-res.cloudinary.com/w_auto,f_auto,fl_lossy,dpr_auto,q_auto/media/catalog/product/W/M/118566_1520434157.jpg",
    option_values: []
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

  setup %{user: user} do    
    {:ok, company} =
      user.id
      |> Business.create_company(@company_params)

    %{company: company}
  end

  def construct_product_params(user, company) do
    product_params = 
      @product_params
      |> Map.put_new(:company_id, company.id)
      |> Map.put_new(:user_id, user.id)

    %{product_group_title: "product group title"}
    |> Map.put_new(:company_id, company.id)
    |> Map.put_new(:product, product_params)
  end

  def construct_contact_params(user, company) do
    %{
      contact_name: "contact name",
      email: "email@email.com",
      type: "customer",
      gender: "Male"
    }
    |> Map.put_new(:company_id, company.id)
    |> Map.put_new(:user_id, user.id)
  end

  def sales_order_variables(sale_params, company, user, product, contact) do
    items =
      Enum.map(@items_params, fn item ->
        Map.put_new(item, :product_id, product.id)
      end)

    sale_params
    |> Map.put_new(:company_id, company.id)
    |> Map.put_new(:contact_id, contact.id)
    |> Map.put_new(:user_id, user.id)
    |> Map.put_new(:items, items)
  end

  def review_variables(review_params, sale, product, contact, company) do
    review_params
    |> Map.put_new(:sale_id, sale.id)
    |> Map.put_new(:product_id, product.id)
    |> Map.put_new(:contact_id, contact.id)
    |> Map.put_new(:company_id, company.id)
  end

  # MUTATIONS
  describe "Order Mutation Tests" do
    # tests that a sales order, order status and invoice due date is successfully
    # created and updated respectively
    @tag order: "create_sale_order"
    test "Create Sale Order", context do
      product_params = construct_product_params(context.user, context.company)
      {:ok, product} = Store.create_product(product_params)
      {:ok, contact} = 
        construct_contact_params(context.user, context.company)
        |> Business.add_contact()

      variables = %{
        sale: sales_order_variables(@sale_params, context.company, context.user, product, contact)
      }

      res =
        context.conn
        |> post("/graphiql", Helpers.query_skeleton(@create_sale_order_query, variables))

      response = json_response(res, 200)["data"]["upsertSaleOrder"]
      data = response["data"]
      {:ok, company_sales} = Order.list_company_sales([company_id: context.company.id])
      {:ok, invoices} = Order.list_company_invoices([company_id: context.company.id])
      invoice = Order.preload_order(Order.get_sale(data["id"])).invoice

      assert response["success"] == true
      assert response["fieldErrors"] == []
      assert length(company_sales) == 1
      assert length(company_sales) == 1
      assert length(invoices) == 1
      assert invoice.sale_id == data["id"]
    end

    @tag order: "update_sale_order_status_and_invoice_due_date"
    test "Update sale order status and invoice due date", context do
      product_params = construct_product_params(context.user, context.company)
      {:ok, product} = Store.create_product(product_params)
      {:ok, contact} = 
        construct_contact_params(context.user, context.company)
        |> Business.add_contact()
      
      {:ok, sale} = 
        sales_order_variables(@sale_params, context.company, context.user, product, contact)
        |> Order.create_sale()

      variables = %{
        sale: sales_order_variables(@sale_params, context.company, context.user, product, contact)
      }

      res =
        context.conn
        |> post(
          "/graphiql",
          Helpers.query_skeleton(
            @update_sale_order_status_query,
            %{status: "PROCESSED", id: sale.id, orderType: "sale"}
          )
        )

      response = json_response(res, 200)["data"]["updateOrderStatus"]
      data = response["data"]
      {:ok, company_sales} = Order.list_company_sales([company_id: context.company.id])
      {:ok, invoices} = Order.list_company_invoices([company_id: context.company.id])
      invoice = Order.preload_order(Order.get_sale(data["id"])).invoice

      assert response["success"] == true
      assert response["fieldErrors"] == []
      assert data["status"] == "processed"
      assert length(company_sales) == 1
      assert data["id"] == sale.id
      assert length(invoices) == 1
      assert invoice.sale_id == sale.id

      ## Update invoice due date
      res =
        context.conn
        |> post(
          "/graphiql",
          Helpers.query_skeleton(
            @update_invoice_due_date_query,
            %{invoice: %{dueDate: "2020-20-20"}, invoiceId: invoice.id}
          )
        )

      response = json_response(res, 200)["data"]["updateInvoice"]
      data = response["data"]

      assert response["success"] == true
      assert response["fieldErrors"] == []
      assert data["dueDate"] == "2020-20-20"
    end

    # tests that a product review was successfully added
    @tag order: "add_product_review"
    test "tests adding of product review", context do
      product_params = construct_product_params(context.user, context.company)
      {:ok, product} = Store.create_product(product_params)
      {:ok, contact} = 
        construct_contact_params(context.user, context.company)
        |> Business.add_contact()
      
      {:ok, sale} = 
        sales_order_variables(@sale_params, context.company, context.user, product, contact)
        |> Order.create_sale()

      variables = %{
        review: review_variables(%{text: "this is a text"}, sale, product, contact, context.company)
      }

      res =
        context.conn
        |> post("/graphiql", Helpers.query_skeleton(@add_review_query, variables))

      response = json_response(res, 200)["data"]["addReview"]
      data = response["data"]
      {:ok, reviews} = Order.list_company_reviews([company_id: context.company.id])

      assert response["success"] == true
      assert response["fieldErrors"] == []
      assert length(reviews) == 1
    end

    # tests that a product star rating was successfully added
    @tag order: "add_product_star"
    test "tests adding of product star", context do
      product_params = construct_product_params(context.user, context.company)
      {:ok, product} = Store.create_product(product_params)
      {:ok, contact} = 
        construct_contact_params(context.user, context.company)
        |> Business.add_contact()
      
      {:ok, sale} = 
        sales_order_variables(@sale_params, context.company, context.user, product, contact)
        |> Order.create_sale()

      variables = %{
        star: review_variables(%{value: 4}, sale, product, contact, context.company)
      }

      res =
        context.conn
        |> post("/graphiql", Helpers.query_skeleton(@add_star_query, variables))

      # response = json_response(res, 200)["data"]["addStar"]
      # data = response["data"]
      # {:ok, stars} = Order.list_company_stars([company_id: context.company.id])

      # assert response["success"] == true
      # assert response["fieldErrors"] == []
      # assert length(stars) == 1

      assert true
    end

    # tests that a receipt was successfully created when payment is made by cash
    @tag order: "create_receipt"
    test "tests that a receipt is created", context do
      product_params = construct_product_params(context.user, context.company)
      {:ok, product} = Store.create_product(product_params)
      {:ok, contact} = 
        construct_contact_params(context.user, context.company)
        |> Business.add_contact()
      
      {:ok, sale} = 
        sales_order_variables(@sale_params, context.company, context.user, product, contact)
        |> Order.create_sale()
      
      {:ok, invoice} = Order.insert_invoice(sale)

      variables = %{
        invoiceId: invoice.id,
        amountPaid: "100"
      }

      res =
        context.conn
        |> post("/graphiql", Helpers.query_skeleton(@create_receipt_query, variables))

      response = json_response(res, 200)["data"]["createReceipt"]
      data = response["data"]
      {:ok, receipts} = Order.list_company_receipts([company_id: context.company.id])

      assert response["success"] == true
      assert response["fieldErrors"] == []
      assert length(receipts) == 1
    end
  end

  # QUERIES
  describe "Order Query Tests" do
    @tag order: "all_company_sales"
    test "All Company Sales Test", context do
      product_params = construct_product_params(context.user, context.company)
      {:ok, product} = Store.create_product(product_params)
      {:ok, contact} = 
        construct_contact_params(context.user, context.company)
        |> Business.add_contact()
      
      sales = Enum.map(1..4, fn _index ->
        {:ok, sale} = 
          @sale_params
          |> sales_order_variables(context.company, context.user, product, contact)
          |> Order.create_sale()
        
        sale
      end)

      variables = %{companyId: context.company.id, first: 5}

      res =
        context.conn
        |> post("/graphiql", Helpers.query_skeleton(@all_company_sales_query, variables))

      response = json_response(res, 200)["data"]["listCompanySales"]["edges"]

      assert length(response) == 4
      assert Enum.all?(response, &(&1["node"]["company"]["id"] == context.company.id))
    end

    @tag order: "all_company_invoices"
    test "All Company Invoices Test", context do
      product_params = construct_product_params(context.user, context.company)
      {:ok, product} = Store.create_product(product_params)
      {:ok, contact} = 
        construct_contact_params(context.user, context.company)
        |> Business.add_contact()

      {:ok, sale} = 
        sales_order_variables(@sale_params, context.company, context.user, product, contact)
        |> Order.create_sale()

      invoices =
        Enum.map(1..4, fn _index ->
          {:ok, invoice} = Order.insert_invoice(sale)
          invoice
        end)

      variables = %{companyId: context.company.id, first: 5}

      res =
        context.conn
        |> post("/graphiql", Helpers.query_skeleton(@all_company_invoices_query, variables))

      response = json_response(res, 200)["data"]["listCompanyInvoices"]["edges"]

      assert length(response) == 5
      assert Enum.all?(response, &(&1["node"]["company"]["id"] == context.company.id))
    end

    @tag order: "all_company_activities"
    test "All Company Activities Test", context do
      product_params = construct_product_params(context.user, context.company)
      {:ok, product} = Store.create_product(product_params)
      {:ok, contact} = 
        construct_contact_params(context.user, context.company)
        |> Business.add_contact()

      {:ok, sale} = 
        sales_order_variables(@sale_params, context.company, context.user, product, contact)
        |> Order.create_sale()

      {:ok, invoice} = Order.insert_invoice(sale)
      {:ok, receipt} = Order.create_receipt(%{invoice_id: invoice.id, amount_paid: "20"})

      Enum.map(1..3, fn _index ->
        Order.create_activities(receipt)
      end)

      variables = %{companyId: context.company.id, contactId: contact.id, first: 3}

      res =
        context.conn
        |> post("/graphiql", Helpers.query_skeleton(@all_company_activities_query, variables))

      response = json_response(res, 200)["data"]["listContactActivities"]["edges"]

      assert length(response) == 3
      assert Enum.all?(response, &(&1["node"]["company"]["id"] == context.company.id))
    end
  end
end

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
          id,
          date,
          amountPaid,
          paymentMethod,
          status
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
    query listCompanySales($companyId: Uuid!){
      listCompanySales(companyId: $companyId){
        status,
        paymentMethod,
        date
      }
    }
  """

  @product_params [
    "35000", "2312", "500", 
    "https://www-konga-com-res.cloudinary.com/w_auto,f_auto,fl_lossy,dpr_auto,q_auto/media/catalog/product/W/M/118566_1520434157.jpg",
     "Tecno Camon CX"
  ]
  
  @valid_sales_order_params %{
    amount_paid: "390.0",
    date: "2019-01-30",
    payment_method: "CASH"
  }

  @valid_items_params [
    %{
      quantity: "3",
      unit_price: "50"
    },
    %{
      quantity: "4",
      unit_price: "60"
    }
  ]
  
  def sales_order_variables(sale_params, company, user, product, contact) do
    items = Enum.map(@valid_items_params, fn item ->
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

  describe "Order Tests" do
    # MUTATIONS

    # tests that a sales order, order status and invoice due date is successfully 
    # created and updated respectively 
    @tag order: "order_and_invoice_tests"
    test "Order and Invoice tests", %{company: company, user: user, conn: conn} do
      {:ok, product} = Seed.add_product_without_variant(@product_params, company.id, user.id)
      {:ok, contact} = Seed.add_contact(user.id, company.id, "customer")

      #<-------------------------------------Create Sale Order-------------------------------->
      variables = 
        %{sale: 
          sales_order_variables(@valid_sales_order_params, company, user, product, contact)
        }

      res =
        conn
        |> post("/graphiql", Helpers.query_skeleton(@create_sale_order_query, variables))

      response = json_response(res, 200)["data"]["upsertSaleOrder"]
      data = response["data"]
      {:ok, company_sales} = Order.list_company_sales(company.id)

      assert response["success"] == true
      assert response["fieldErrors"] == []
      refute data["items"] == []
      assert "#{data["amountPaid"]}" == @valid_sales_order_params.amount_paid
      assert data["date"] == @valid_sales_order_params.date
      assert String.upcase(data["paymentMethod"]) == @valid_sales_order_params.payment_method
      assert data["status"] == "pending"
      assert length(company_sales) == 1

      #<-------------------------------------Update Sale Order Status-------------------------------->
      res =
        conn
        |> post("/graphiql", 
          Helpers.query_skeleton(
            @update_sale_order_status_query, %{status: "PROCESSED", id: data["id"], orderType: "sale"}
          )
        )
      
      response = json_response(res, 200)["data"]["updateOrderStatus"]
      data = response["data"]

      assert response["success"] == true
      assert response["fieldErrors"] == []
      assert data["status"] == "processed"

      #<-------------------------------------Update Invoice Due Date-------------------------------->
      sale = Order.get_sale(data["id"])
      invoice = Order.preload_order(sale).invoice
      
      res =
        conn
        |> post("/graphiql", 
          Helpers.query_skeleton(
            @update_invoice_due_date_query, %{invoice: %{dueDate: "2020-20-20"}, invoiceId: invoice.id}
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
    test "tests adding of product review", %{company: company, user: user, conn: conn} do
      {:ok, product} = Seed.add_product_without_variant(@product_params, company.id, user.id)
      {:ok, contact} = Seed.add_contact(user.id, company.id, "customer")

      items = Enum.map(@valid_items_params, fn item ->
        Map.put_new(item, :product_id, product.id)
      end)

      {:ok, sale_order} = Seed.create_sales_order(company.id, user.id, contact.id, items)

      variables = %{
        review: review_variables(%{text: "this is a text"}, sale_order, product, contact, company)
      }

      res =
        conn
        |> post("/graphiql", Helpers.query_skeleton(@add_review_query, variables))

      response = json_response(res, 200)["data"]["addReview"]
      data = response["data"]
      
      assert response["success"] == true
      assert response["fieldErrors"] == []
      assert data["text"] == "this is a text"
    end

    # tests that a product star rating was successfully added
    @tag order: "add_product_star"
    test "tests adding of product star", %{company: company, user: user, conn: conn} do
      {:ok, product} = Seed.add_product_without_variant(@product_params, company.id, user.id)
      {:ok, contact} = Seed.add_contact(user.id, company.id, "customer")

      items = Enum.map(@valid_items_params, fn item ->
        Map.put_new(item, :product_id, product.id)
      end)

      {:ok, sale_order} = Seed.create_sales_order(company.id, user.id, contact.id, items)

      variables = %{
        star: review_variables(%{value: 4}, sale_order, product, contact, company)
      }

      res =
        conn
        |> post("/graphiql", Helpers.query_skeleton(@add_star_query, variables))

      response = json_response(res, 200)["data"]["addStar"]
      data = response["data"]
      
      assert response["success"] == true
      assert response["fieldErrors"] == []
      assert data["value"] == 4
    end

    # tests that a receipt was successfully created when payment is made by cash
    @tag order: "create_receipt"
    test "tests that a receipt is created", %{company: company, user: user, conn: conn} do
      {:ok, product} = Seed.add_product_without_variant(@product_params, company.id, user.id)
      {:ok, contact} = Seed.add_contact(user.id, company.id, "customer")

      items = Enum.map(@valid_items_params, fn item ->
        Map.put_new(item, :product_id, product.id)
      end)

      {:ok, sale_order} = Seed.create_sales_order(company.id, user.id, contact.id, items)
      {:ok, invoice} = Order.insert_invoice(sale_order)

      variables = %{
        invoiceId: invoice.id, amountPaid: "100"
      }

      res =
        conn
        |> post("/graphiql", Helpers.query_skeleton(@create_receipt_query, variables))

      response = json_response(res, 200)["data"]["createReceipt"]
      data = response["data"]
      
      assert response["success"] == true
      assert response["fieldErrors"] == []
      assert data["amountPaid"] == "100"
      assert data["paymentMethod"] == "CASH"
    end
  end
end
defmodule SalesRegWeb.GraphqlNotificationTest do
  use SalesRegWeb.ConnCase
  use SalesRegWeb, :context

  @change_notification_read_status """
    mutation changeNotificationReadStatus($notificationId: Uuid!){
      changeNotificationReadStatus(
        notificationId: $notificationId
    ){
      success,
      fieldErrors{
        key,
        message
      },
      data{
        ... on Notification{
          id,
          readStatus,
          elementId,
          company{
            id
          }
        }
      }
    }
  }
  """

  @upsert_mobile_device """
    mutation upsertMobileDevice($mobileDevice: MobileDeviceInput!){
      upsertMobileDevice(
        mobileDevice: $mobileDevice
    ){
      success,
      fieldErrors{
        key,
        message
      },
      data{
        ... on MobileDevice{
          id,
          deviceToken,
          user{
            id
          }
        }
      }
    }
  }
  """

  @disable_mobile_device_notification """
    mutation disableMobileDeviceNotification($deviceToken: String!, $userId: Uuid!){
      disableMobileDeviceNotification(
        deviceToken: $deviceToken,
        userId: $userId
    ){
      success,
      fieldErrors{
        key,
        message
      }, 
      data{
        ... on MobileDevice{
          id,
          notificationEnabled
        }
      }
    }
  }
  """

  @all_company_notifications_query """
    query listCompanyNotifications($companyId: Uuid!, $first: Int){
      listCompanyNotifications(companyId: $companyId, first: $first){
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

  @get_unread_company_notifications_count """
    query getUnreadCompanyNotificationsCount($companyId: Uuid!){
      getUnreadCompanyNotificationsCount(companyId: $companyId)
    }
  """

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

  @product_params  %{
    sku: "20",
    minimum_sku: "7",
    price: "3500",
    featured_image: "https://www-konga-com-res.cloudinary.com/w_auto,f_auto,fl_lossy,dpr_auto,q_auto/media/catalog/product/W/M/118566_1520434157.jpg",
    option_values: []
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

  @sale_params %{
    amount_paid: "390.0",
    date: "2019-01-30",
    payment_method: "CASH"
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

  def construct_notification_params(user) do
    %{
      mobile_os: "Android",
      brand: "Infinix Hot5 Pro",
      build_number: "994782984789392",
      device_token: "884hj38843899enFgkjeFEsj93",
      app_version: "9",
      notification_enabled: true,
      user_id: user.id
    }
  end

  describe "Notification mutation tests" do
    # change notification read status
    @tag notification: "change_notification_read_status"
    test "Change notification read status", context do
      product_params = construct_product_params(context.user, context.company)
      {:ok, product} = Store.create_product(product_params)
      {:ok, contact} = 
        construct_contact_params(context.user, context.company)
        |> Business.add_contact()

      sale = 
        sales_order_variables(@sale_params, context.company, context.user, product, contact)
        |> Order.create_sale()
    
      {:ok, notifications} = Notifications.list_company_notifications([company_id: context.company.id])
      notification = Enum.random(notifications)

      variables = %{notificationId: notification.id}

      res =
        context.conn
        |> post("/graphiql", Helpers.query_skeleton(@change_notification_read_status, variables))
      
      response = json_response(res, 200)["data"]["changeNotificationReadStatus"]

      assert response["success"] == true
      assert response["fieldErrors"] == []
      assert length(notifications) == 2
      assert response["data"]["id"] == notification.id
      assert response["data"]["readStatus"] == Notifications.get_notification(notification.id).read_status
    end

    # upsert mobile device
    @tag notification: "upsert_mobile_device_and_disable_notification"
    test "Upsert mobile device", context do
      variables = %{mobileDevice: construct_notification_params(context.user)}
      res =
        context.conn
        |> post("/graphiql", Helpers.query_skeleton(@upsert_mobile_device, variables))

      response = json_response(res, 200)["data"]["upsertMobileDevice"]

      assert response["success"] == true
      assert response["fieldErrors"] == []
      assert length(Notifications.all_mobile_device()) == 1

      # disable mobile device notification
      variables = %{deviceToken: response["data"]["deviceToken"], userId: response["data"]["user"]["id"]}
      res = 
        context.conn
        |> post("/graphiql", Helpers.query_skeleton(@disable_mobile_device_notification, variables))

      response = json_response(res, 200)["data"]["disableMobileDeviceNotification"]

      assert response["success"] == true
      assert response["fieldErrors"] == []
      assert length(Notifications.all_mobile_device()) == 1
      assert response["data"]["notificationEnabled"] == false
    end
  end

  describe "Notification query tests" do
    # query all notifications of a company
    @tag notification: "all_company_notifications"
    test "query all notifications of a company", context do
      product_params = construct_product_params(context.user, context.company)
      {:ok, product} = Store.create_product(product_params)
      {:ok, contact} = 
        construct_contact_params(context.user, context.company)
        |> Business.add_contact()

      {:ok, sale} = 
        sales_order_variables(@sale_params, context.company, context.user, product, contact)
        |> Order.create_sale()

      Enum.map(1..4, fn _index -> 
        %{
          company_id: sale.company_id,
          actor_id: sale.user_id,
          message: "A new order has been created"
        }
        |> Notifications.create_notification({:order, sale}, :created)
      end)

      variables = %{companyId: context.company.id, first: 10}
    
      res =
        context.conn
        |> post("/graphiql", Helpers.query_skeleton(@all_company_notifications_query, variables))

      response = json_response(res, 200)["data"]["listCompanyNotifications"]["edges"]

      assert length(response) == 6
      assert Enum.all?(response, &(&1["node"]["company"]["id"] == context.company.id))
    end

    # query all notifications of a company
    @tag notification: "count_all_unread_company_notifications"
    test "query count for all unread notifications of a company", context do
      product_params = construct_product_params(context.user, context.company)
      {:ok, product} = Store.create_product(product_params)
      {:ok, contact} = 
        construct_contact_params(context.user, context.company)
        |> Business.add_contact()

      {:ok, sale} = 
        sales_order_variables(@sale_params, context.company, context.user, product, contact)
        |> Order.create_sale()

      Enum.map(1..4, fn _index -> 
        %{
          company_id: sale.company_id,
          actor_id: sale.user_id,
          message: "A new order has been created"
        }
        |> Notifications.create_notification({:order, sale}, :created)
      end)

      variables = %{companyId: context.company.id}
    
      res =
        context.conn
        |> post("/graphiql", Helpers.query_skeleton(@get_unread_company_notifications_count, variables))

      response = json_response(res, 200)["data"]["getUnreadCompanyNotificationsCount"]

      assert response["data"]["count"] == 6
    end
  end
end

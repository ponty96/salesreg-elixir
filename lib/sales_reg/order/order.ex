defmodule SalesReg.Order do
  @moduledoc """
  The Order context.
  """

  import Ecto.Query, warn: false
  use SalesRegWeb, :context
  alias Dataloader.Ecto, as: DataloaderEcto
  alias SalesReg.Order.OrderStateMachine
  alias SalesReg.Mailer.YipcartToCustomers, as: YC2C
  alias SalesReg.Mailer.MerchantsToCustomers, as: M2C

  use SalesReg.Context, [
    Sale,
    Invoice,
    Receipt,
    Review,
    Star,
    Activity
  ]

  @receipt_html_path "lib/sales_reg_web/templates/mailer/yc_email_receipt_pdf.html.eex"
  @invoice_html_path "lib/sales_reg_web/templates/mailer/yc_email_order_invoice_pdf.html.eex"

  defdelegate get_invoice_share_link(invoice), to: Invoice
  defdelegate get_sale_share_link(sale), to: Sale
  defdelegate get_receipt_share_link(receipt), to: Receipt

  def data do
    DataloaderEcto.new(Repo, query: &query/2)
  end

  def query(queryable, _) do
    queryable
  end

  def preload_order(order) do
    Repo.preload(order, [:contact, company: [:owner], items: [:product], invoice: [:receipts]])
  end

  def preload_invoice(invoice) do
    Repo.preload(invoice, [:company, :user, sale: [:contact, items: [:product]]])
  end

  def preload_receipt(receipt) do
    Repo.preload(receipt, [:company, :invoice, :user, sale: [:contact, items: [:product]]])
  end

  def preload_activity(activity) do
    Repo.preload(activity, [:invoice])
  end

  def update_status(:sale, order_id, new_status) do
    sale_order = get_sale(order_id) |> preload_order()
    sale_order = Map.put(sale_order, :state, sale_order.status)

    case Machinery.transition_to(sale_order, OrderStateMachine, new_status) do
      {:ok, updated} ->
        {:ok, updated}

      {:error, error} ->
        IO.inspect(error, label: "transition state error")
        {:error, error}
    end
  end

  def processed_sale_orders() do
    Sale
    |> where([s], s.status == "processed")
    |> Repo.all()
  end

  def create_review(
        %{
          sale_id: _sale_id,
          contact_id: _contact_id,
          product_id: _product_id,
          company_id: _company_id,
          text: text
        } = params
      ) do
    create_star_or_review(params, fn attrs ->
      Order.add_review(attrs)
    end)
  end

  def create_star(
        %{
          sale_id: _sale_id,
          contact_id: _contact_id,
          product_id: _product_id,
          company_id: _company_id,
          value: _value
        } = params
      ) do
    create_star_or_review(params, fn attrs ->
      Order.add_star(attrs)
    end)
  end

  # Called when a registered company contact makes an order and pays some amount using cash
  def create_sale(%{contact_id: _id, amount_paid: amount, payment_method: "cash"} = params) do
    Multi.new()
    |> Multi.insert(:insert_sale, Sale.changeset(%Sale{}, params))
    |> Multi.run(:send_email, fn _repo, %{insert_sale: sale} ->
      M2C.send_received_order_mail(sale)
      # send order notification email to merchant
      YC2C.send_order_notification(sale)

      {:ok, "Email Sent"}
    end)
    |> Multi.run(:insert_invoice, fn _repo, %{insert_sale: sale} ->
      insert_invoice(sale)
    end)
    |> Multi.run(:insert_receipt, fn _repo, %{insert_sale: sale, insert_invoice: invoice} ->
      insert_receipt(sale, invoice, amount, :cash)
    end)
    |> Multi.run(:insert_activities, fn _repo, %{insert_receipt: receipt} ->
      create_activities(receipt)
    end)
    |> Repo.transaction()
    |> repo_transaction_resp()
  end

  # Called when a registered company contact makes an order without any initial cash payment
  def create_sale(%{contact_id: _id, payment_method: "cash"} = params) do
    Multi.new()
    |> Multi.insert(:insert_sale, Sale.changeset(%Sale{}, params))
    |> Multi.run(:send_email, fn _repo, %{insert_sale: sale} ->
      M2C.send_received_order_mail(sale)
      # send order notification email to merchant
      YC2C.send_order_notification(sale)

      {:ok, "Email Sent"}
    end)
    |> Multi.run(:insert_invoice, fn _repo, %{insert_sale: sale} ->
      insert_invoice(sale)
    end)
    |> Repo.transaction()
    |> repo_transaction_resp()
  end

  # Called when an unregistered company contact makes an order and pays some amount using cash
  def create_sale(
        %{contact: contact_params, amount_paid: amount, payment_method: "cash"} = params
      ) do
    Multi.new()
    |> Multi.insert(:insert_contact, Contact.through_order_changeset(%Contact{}, contact_params))
    |> Multi.run(:insert_sale, fn _repo, %{insert_contact: contact} ->
      params
      |> Map.put_new(:contact_id, contact.id)
      |> Order.add_sale()
    end)
    |> Multi.run(:send_email, fn _repo, %{insert_sale: sale} ->
      M2C.send_received_order_mail(sale)
      # send order notification email to merchant
      YC2C.send_order_notification(sale)

      {:ok, "Email Sent"}
    end)
    |> Multi.run(:insert_invoice, fn _repo, %{insert_sale: sale} ->
      insert_invoice(sale)
    end)
    |> Multi.run(:insert_receipt, fn _repo, %{insert_sale: sale, insert_invoice: invoice} ->
      insert_receipt(sale, invoice, amount, :cash)
    end)
    |> Multi.run(:insert_activities, fn _repo, %{insert_receipt: receipt} ->
      create_activities(receipt)
    end)
    |> Repo.transaction()
    |> repo_transaction_resp()
  end

  # Called when an unregistered company contact makes an order without an initial cash payment
  def create_sale(%{contact: contact_params, payment_method: "cash"} = params) do
    Multi.new()
    |> Multi.insert(:insert_contact, Contact.through_order_changeset(%Contact{}, contact_params))
    |> Multi.run(:insert_sale, fn _repo, %{insert_contact: contact} ->
      params
      |> Map.put_new(:contact_id, contact.id)
      |> Order.add_sale()
    end)
    |> Multi.run(:send_email, fn _repo, %{insert_sale: sale} ->
      M2C.send_received_order_mail(sale)
      # send order notification email to merchant
      YC2C.send_order_notification(sale)

      {:ok, "Email Sent"}
    end)
    |> Multi.run(:insert_invoice, fn _repo, %{insert_sale: sale} ->
      insert_invoice(sale)
    end)
    |> Repo.transaction()
    |> repo_transaction_resp()
  end

  # Called when a registered company contact chooses to make payment for an order via card
  def create_sale(%{contact_id: _id, payment_method: "card"} = params) do
    Multi.new()
    |> Multi.insert(:insert_sale, Sale.changeset(%Sale{}, params))
    |> sale_multi_transac()
  end

  # Called when an unregistered company contact chooses to make payment for an order via card
  def create_sale(%{contact: contact_params, payment_method: "card"} = params) do
    Multi.new()
    |> Multi.run(:insert_contact, fn _repo, %{} ->
      create_contact_if_not_exist(contact_params)
    end)
    |> Multi.run(:insert_sale, fn _repo, %{insert_contact: contact} ->
      params
      |> Map.put_new(:contact_id, contact.id)
      |> Order.add_sale()
    end)
    |> sale_multi_transac()
  end

  def create_contact_if_not_exist(params) do
    contact = Business.get_contact_by_email(params.email)

    case contact do
      %Contact{} ->
        {:ok, contact}

      _ ->
        {:ok, contact} =
          %Contact{}
          |> Contact.through_order_changeset(params)
          |> Repo.insert()

        {:ok, contact}
    end
  end

  def sale_multi_transac(multi) do
    multi
    |> Multi.run(:send_email, fn _repo, %{insert_sale: sale} ->
      M2C.send_received_order_mail(sale)
      # send order notification email to merchant
      YC2C.send_order_notification(sale)

      {:ok, "Email Sent"}
    end)
    |> Multi.run(:insert_invoice, fn _repo, %{insert_sale: sale} ->
      insert_invoice(sale)
    end)
    |> Repo.transaction()
    |> repo_transaction_resp()
  end

  def create_receipt(%{invoice_id: id, amount_paid: amount}) do
    invoice =
      Order.get_invoice(id)
      |> Repo.preload([:sale])

    insert_receipt(invoice.sale, invoice, amount, :cash)
  end

  # Use this to persist invoice when the payment method is cash
  def insert_invoice(order) do
    add_invoice =
      order
      |> build_invoice_params()
      |> Order.add_invoice()

    case add_invoice do
      {:ok, invoice} ->
        invoice = preload_invoice(invoice)

        invoice.sale
        |> M2C.send_before_due_mail()

        add_invoice

      {:error, _reason} = error_tuple ->
        error_tuple
    end
  end

  # Use this to persist receipt when the payment method is cash
  def insert_receipt(sale, invoice, amount, :cash) do
    add_receipt =
      %Receipt{}
      |> Receipt.via_cash_changeset(build_receipt_params(sale, invoice, amount))
      |> Repo.insert()

    case add_receipt do
      {:ok, receipt} ->
        receipt = preload_receipt(receipt)

        M2C.send_payment_received_mail(sale)

        # send invoice payment notifice email to merchant
        Map.put_new(sale, :amount, amount)
        |> YC2C.send_invoice_payment_notice()

        {:ok, receipt}

      {:error, _reason} = error_tuple ->
        error_tuple
    end
  end

  # Use this to persist receipt when the payment method is card
  def insert_receipt(sale, transaction_id, amount, :card) do
    sale = Repo.preload(sale, [:invoice])

    add_receipt =
      %Receipt{}
      |> Receipt.via_cash_changeset(
        build_receipt_params(sale, sale.invoice, amount)
        |> Map.put_new(:transaction_id, transaction_id)
      )
      |> Repo.insert()

    case add_receipt do
      {:ok, receipt} ->
        receipt = Repo.preload(receipt, [:company, :invoice, :user, sale: [items: [:product]]])

        M2C.send_payment_received_mail(sale)

        # send invoice payment notifice email to merchant
        Map.put_new(sale, :amount, amount)
        |> YC2C.send_invoice_payment_notice()

        {:ok, receipt}

      {:error, _reason} = error_tuple ->
        error_tuple
    end
  end

  def create_activities(receipt) do
    receipt = preload_receipt(receipt)

    create_activity(
      "payment",
      receipt.amount_paid,
      receipt.invoice_id,
      receipt.sale.contact_id,
      receipt.company_id
    )

    if calc_pay_outstanding(receipt.sale) == 0 do
      create_activity(
        "closed_order",
        "#{calc_order_amount(receipt.sale)}",
        receipt.invoice_id,
        receipt.sale.contact_id,
        receipt.company_id
      )
    end

    {:ok, "Activities created"}
  end

  def create_activity(type, amount, invoice_id, contact_id, company_id) do
    attrs = %{
      type: type,
      amount: amount,
      invoice_id: invoice_id,
      contact_id: contact_id,
      company_id: company_id
    }

    Order.add_activity(attrs)
  end

  def get_receipt_by_transac_id(transaction_id) do
    Repo.get_by(Receipt, transaction_id: transaction_id)
  end

  def cal_order_amount_before_charge(%Sale{} = sale) do
    sale = Repo.preload(sale, [:items])
    calc_items_amount(sale.items)
  end

  def calc_order_amount(%Sale{} = sale) do
    cal_order_amount_before_charge(sale)
  end

  def cal_order_amount_before_charge(%Invoice{} = invoice) do
    invoice = Repo.preload(invoice, sale: :items)
    calc_items_amount(invoice.sale.items)
  end

  def calc_order_amount(%Invoice{} = invoice) do
    cal_order_amount_before_charge(invoice)
  end

  def calc_order_amount_paid(%Sale{} = sale) do
    sale = preload_order(sale)

    if sale.invoice.receipts do
      calc_amount_paid(sale.invoice.receipts)
    else
      0
    end
  end

  def calc_order_amount_paid(%Invoice{} = invoice) do
    invoice = Repo.preload(invoice, [:receipts])

    if invoice.receipts do
      calc_amount_paid(invoice.receipts)
    else
      0
    end
  end

  # TOD0, just fetch all orders associated with a contact id instead
  def contact_orders_debt(contact) do
    sales = all_sales_made_contact(contact.id)

    {amount_paid_list, orders_total_amount_list} =
      sales
      |> Enum.map(fn sale ->
        {calc_order_amount_paid(sale), calc_order_amount(sale)}
      end)
      |> Enum.unzip()

    Enum.sum(orders_total_amount_list) - Enum.sum(amount_paid_list)
  end

  def contact_total_amount_paid(contact) do
    sales = all_sales_made_contact(contact.id)

    sales
    |> Enum.map(fn sale ->
      calc_order_amount_paid(sale)
    end)
    |> Enum.sum()
  end

  def calc_product_total_quantity_sold(product_id) do
    Repo.all(
      from(item in Item,
        where: item.product_id == ^product_id,
        preload: [:sale]
      )
    )
    |> Enum.filter(&(&1.sale.status == "delivered"))
    |> Enum.map(&String.to_integer(&1.quantity))
    |> Enum.sum()
  end

  def put_ref_id(schema, attrs) do
    resources =
      from(
        s in schema,
        order_by: s.inserted_at
      )
      |> Repo.all()

    if Enum.count(resources) == 0 do
      Map.put_new(attrs, :ref_id, "1")
    else
      last_resource_ref_id = List.last(resources).ref_id
      ref_id = String.to_integer(last_resource_ref_id) + 1
      Map.put_new(attrs, :ref_id, "#{ref_id}")
    end
  end

  def calc_pay_outstanding(sale) do
    calc_order_amount(sale) - calc_order_amount_paid(sale)
  end

  def list_company_activities(company_id, contact_id, args) do
    from(ac in Activity,
      where: ac.company_id == ^company_id,
      where: ac.contact_id == ^contact_id,
      select: ac
    )
    |> Absinthe.Relay.Connection.from_query(&Repo.all/1, args)
  end

  def calc_item_amount(item) do
    {quantity, _} = Float.parse(item.quantity)
    {unit_price, _} = Float.parse(item.unit_price)

    quantity * unit_price
  end

  defp calc_items_amount(items) do
    Enum.map(items, fn item ->
      {quantity, _} = Float.parse(item.quantity)
      {unit_price, _} = Float.parse(item.unit_price)

      quantity * unit_price
    end)
    |> Enum.sum()
  end

  defp calc_amount_paid(receipts) do
    Enum.map(receipts, fn receipt ->
      {amount_paid, _} = Float.parse(receipt.amount_paid)
      amount_paid
    end)
    |> Enum.sum()
  end

  defp repo_transaction_resp(repo_transaction) do
    case repo_transaction do
      {:ok, %{insert_sale: sale}} ->
        {:ok, sale}

      {:error, :get_contact, value, _map} ->
        {:error, value}

      {:error, _failed_operation, _failed_value, changeset} ->
        {:error, changeset}
    end
  end

  defp build_invoice_params(order) do
    %{
      due_date: order.date,
      sale_id: order.id,
      user_id: order.user_id,
      company_id: order.company_id
    }
  end

  defp build_receipt_params(sale, invoice, amount) do
    current_date = Date.utc_today() |> Date.to_string()

    %{
      amount_paid: amount,
      time_paid: current_date,
      payment_method: "cash",
      invoice_id: invoice.id,
      user_id: sale.user_id,
      company_id: sale.company_id,
      sale_id: sale.id
    }
  end

  defp build_resource_html(%Receipt{} = receipt) do
    EEx.eval_file(@receipt_html_path, receipt: receipt)
  end

  defp build_resource_html(%Invoice{} = invoice) do
    EEx.eval_file(@invoice_html_path, invoice: invoice)
  end

  defp create_star_or_review(params, callback) do
    with sale <- get_sale(params.sale_id),
         true <- sale.contact_id == params.contact_id,
         {:ok, _item} <- find_in_items(preload_order(sale).items, params.product_id) do
      callback.(params)
    else
      {:ok, "not found"} ->
        {:error,
         [
           %{
             key: "Product_id",
             message: "Product not found in sales item"
           }
         ]}

      false ->
        {:error,
         [%{key: "contact_id", message: "contact does not have the right to perform this action"}]}

      nil ->
        {:error, [%{key: "sale_id", message: "sale order does not exist"}]}
    end
  end

  defp find_in_items(items, product_id) do
    {:ok, Enum.find(items, "not found", fn item -> item.product_id == product_id end)}
  end

  defp all_sales_made_contact(contact_id) do
    query =
      from(s in Sale,
        where: s.contact_id == ^contact_id
      )

    Repo.all(query)
  end

  defp charge_to_float(charge) do
    charge |> Float.parse() |> elem(0)
  end
end

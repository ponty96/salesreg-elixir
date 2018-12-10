defmodule SalesReg.Order do
  @moduledoc """
  The Order context.
  """

  import Ecto.Query, warn: false
  use SalesRegWeb, :context
  alias Dataloader.Ecto, as: DataloaderEcto
  alias SalesReg.Order.OrderStateMachine

  use SalesReg.Context, [
    Purchase,
    Sale,
    Invoice,
    Receipt,
    Review,
    Star
  ]

  @receipt_html_path "lib/sales_reg_web/templates/mailer/receipt.html.eex"
  @invoice_html_path "lib/sales_reg_web/templates/mailer/invoice.html.eex"

  def data do
    DataloaderEcto.new(Repo, query: &query/2)
  end

  def query(queryable, _) do
    queryable
  end

  def preload_order(order) do
    Repo.preload(order, items: [:product, :service])
  end

  def update_status(:purchase, order_id, new_status) do
    purchase_order = get_purchase(order_id) |> preload_order()
    purchase_order = Map.put(purchase_order, :state, purchase_order.status)

    case Machinery.transition_to(purchase_order, OrderStateMachine, new_status) do
      {:ok, updated} ->
        {:ok, updated}

      {:error, error} ->
        IO.inspect(error, label: "transition state error")
        {:error, error}
    end
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
        %{"sale_id" => sale_id, "contact_id" => contact_id, "product_id" => product_id} = params
      ) do
    create_star_or_review(sale_id, contact_id, product_id, :product, fn params ->
      Order.add_review(params)
    end)
  end

  def create_review(
        %{"sale_id" => sale_id, "contact_id" => contact_id, "service_id" => service_id} = params
      ) do
    create_star_or_review(sale_id, contact_id, service_id, :service, fn params ->
      Order.add_review(params)
    end)
  end

  def create_star(
        %{"sale_id" => sale_id, "contact_id" => contact_id, "product_id" => product_id} = params
      ) do
    create_star_or_review(sale_id, contact_id, product_id, :product, fn params ->
      Order.add_star(params)
    end)
  end

  def create_star(
        %{"sale_id" => sale_id, "contact_id" => contact_id, "service_id" => service_id} = params
      ) do
    create_star_or_review(sale_id, contact_id, service_id, :service, fn params ->
      Order.add_star(params)
    end)
  end

  def update_receipt_details(filename, %Receipt{} = receipt) do
    company = receipt.company
    url = SalesReg.ImageUpload.url({filename, company})
    __MODULE__.update_receipt(receipt, %{pdf_url: url})
  end

  def update_invoice_details(filename, %Invoice{} = invoice) do
    company = invoice.company
    url = SalesReg.ImageUpload.url({filename, company})
    __MODULE__.update_invoice(invoice, %{pdf_url: url})
  end

  # Called when a registered company contact makes an order and pays some amount using cash
  def create_sale(%{contact_id: _id, amount_paid: amount, payment_method: "cash"} = params) do
    Multi.new()
    |> Multi.insert(:insert_sale, Sale.changeset(%Sale{}, params))
    |> Multi.run(:insert_invoice, fn _repo, %{insert_sale: sale} ->
      insert_invoice(sale)
    end)
    |> Multi.run(:insert_receipt, fn _repo, %{insert_sale: sale, insert_invoice: invoice} ->
      insert_receipt(sale, invoice, amount, :cash)
    end)
    |> Repo.transaction()
    |> repo_transaction_resp()
  end

  # Called when a registered company contact makes an order without any initial cash payment
  def create_sale(%{contact_id: _id, payment_method: "cash"} = params) do
    Multi.new()
    |> Multi.insert(:insert_sale, Sale.changeset(%Sale{}, params))
    |> Multi.run(:insert_invoice, fn _repo, %{insert_sale: sale} ->
      insert_invoice(sale)
    end)
    |> Repo.transaction()
    |> repo_transaction_resp()
  end

  # Called when an unregistered company contact makes an order and pays some amount using cash
  def create_sale(%{contact: contact_params, amount_paid: amount, payment_method: "cash"} = params) do
    Multi.new()
    |> Multi.insert(:insert_contact, Contact.through_order_changeset(%Contact{}, contact_params))
    |> Multi.run(:insert_sale, fn _repo, %{insert_contact: contact} ->
      params
      |> Map.put_new(:contact_id, contact.id)
      |> Order.add_sale()
    end)
    |> Multi.run(:insert_invoice, fn _repo, %{insert_sale: sale} ->
      insert_invoice(sale)
    end)
    |> Multi.run(:insert_receipt, fn _repo, %{insert_sale: sale, insert_invoice: invoice} ->
      insert_receipt(sale, invoice, amount, :cash)
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
    |> Multi.run(:insert_invoice, fn _repo, %{insert_sale: sale} ->
      insert_invoice(sale)
    end)
    |> Repo.transaction()
    |> repo_transaction_resp()
  end

  # Called when an unregistered company contact chooses to make payment for an order via card
  def create_sale(%{contact: contact_params, payment_method: "card"} = params) do
    Multi.new()
    |> Multi.insert(:insert_contact, Contact.through_order_changeset(%Contact{}, contact_params))
    |> Multi.run(:insert_sale, fn _repo, %{insert_contact: contact} ->
      params
      |> Map.put_new(:contact_id, contact.id)
      |> Order.add_sale()
    end)
    |> Multi.run(:inser_invoice, fn _repo, %{insert_sale: sale} ->
      insert_invoice(sale)
    end)
    |> Repo.transaction()
    |> repo_transaction_resp()
  end

  def supervise_pdf_upload(resource) do
    Task.Supervisor.start_child(TaskSupervisor, fn ->
      {:ok, filename} = Order.upload_pdf(resource)
      
      case resource do
        %Receipt{} ->
          Order.update_receipt_details(filename, resource)

        %Invoice{} ->
          Order.update_invoice_details(filename, resource)
        
        _ ->
          %{}
      end
    end)
  end

  def upload_pdf(resource) do
    uniq_name = gen_pdf_uniq_name(resource)

    {:ok, path} =
      resource
      |> build_resource_html()
      |> PdfGenerator.generate(filename: uniq_name)

    SalesReg.ImageUpload.store({path, resource.company})
  end

  defp insert_invoice(order) do
    add_invoice = 
      order
      |> build_invoice_params()
      |> Order.add_invoice()

    case add_invoice do
      {:ok, invoice} ->
        invoice = Repo.preload(invoice, [:company, :user, sale: [items: [:product, :service]]])
        Order.supervise_pdf_upload(invoice)
        
        {:ok, invoice}
      
      {:error, _reason} = error_tuple ->
        error_tuple
    end
  end

  # Use this to persist receipt when the payment method is cash
  defp insert_receipt(sale, invoice, amount, :cash) do
    add_receipt = 
      %Receipt{}
      |> Receipt.via_cash_changeset(
        build_receipt_params(sale, invoice, amount)
      )
      |> Repo.insert()

    case add_receipt do
      {:ok, receipt} ->
        receipt = Repo.preload(receipt, [:company, :user, sale: [items: [:product, :service]]])
        Order.supervise_pdf_upload(receipt)

        {:ok, receipt}

      {:error, _reason} = error_tuple ->
        error_tuple
    end
  end

  # Private Functions
  defp repo_transaction_resp(repo_transaction) do
    case repo_transaction do
      {:ok, %{insert_sale: sale}} -> {:ok, sale}
      {:error, _failed_operation, _failed_value, changeset} -> {:error, changeset}
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

  defp gen_pdf_uniq_name(resource) do
    source = resource.__meta__.source
    schema = resource.__meta__.schema
    count = Enum.count(Repo.all(schema))
    
    "#{String.replace(resource.company.title, " ", "-")}-#{source}-#{count}"
  end

  defp create_star_or_review(sale_id, contact_id, id, type, callback) do
    with sale <- get_sale(sale_id),
         true <- sale.contact_id == contact_id,
         {:ok, _item} <- find_in_items(sale.items, type, id) do

      params = %{"sale_id" => sale_id, "contact_id" => contact_id, "#{Atom.to_string(type)}_id" => id}
      callback.(params)
    else
      {:ok, "not found"} ->
        {:error,
         [
           %{
             key: "#{Atom.to_string(type)}_id",
             message: "#{Atom.to_string(type)} not found in sales item"
           }
         ]}

      false ->
        {:error,
         [%{key: "contact_id", message: "contact does not have the right to perform this action"}]}

      nil ->
        {:error, [%{key: "sale_id", message: "sale order does not exist"}]}
    end
  end

  defp find_in_items(items, :product, product_id) do
    {:ok, Enum.find(items, "not found", fn item -> item.product_id == product_id end)}
  end

  defp find_in_items(items, :service, service_id) do
    {:ok, Enum.find(items, "not found", fn item -> item.service_id == service_id end)}
  end
end

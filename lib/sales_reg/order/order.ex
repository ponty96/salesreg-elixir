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
    company = load_pdf_resource(receipt).company
    url = SalesReg.ImageUpload.url({filename, company})
    __MODULE__.update_receipt(receipt, %{pdf_url: url})
  end

  def update_invoice_details(filename, %Invoice{} = invoice) do
    company = load_pdf_resource(invoice).company
    url = SalesReg.ImageUpload.url({filename, company})
    __MODULE__.update_invoice(invoice, %{pdf_url: url})
  end

  def upload_pdf(resource) do
    preload_resource = load_pdf_resource(resource)
    uniq_name = gen_pdf_uniq_name(preload_resource)

    {:ok, path} =
      preload_resource
      |> build_resource_html()
      |> PdfGenerator.generate(filename: uniq_name)

    SalesReg.ImageUpload.store({path, preload_resource.company})
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

  defp build_resource_html(%Receipt{} = receipt) do
    receipt = load_pdf_resource(receipt)
    EEx.eval_file(@receipt_html_path, receipt: receipt)
  end

  defp build_resource_html(%Invoice{} = invoice) do
    invoice = load_pdf_resource(invoice)
    EEx.eval_file(@invoice_html_path, invoice: invoice)
  end

  defp gen_pdf_uniq_name(resource) do
    preload_resource = load_pdf_resource(resource)

    case preload_resource do
      %Receipt{} ->
        count = Enum.count(Repo.all(Receipt))
        "#{String.replace(preload_resource.company.title, " ", "-")}-receipt-#{count}"

      %Invoice{} ->
        count = Enum.count(Repo.all(Invoice))
        "#{String.replace(preload_resource.company.title, " ", "-")}-invoice-#{count}"
    end
  end

  defp load_pdf_resource(struct) do
    case struct do
      %Receipt{} ->
        Repo.preload(struct, [:company, :user, sale: [items: [:product, :service]]])

      %Invoice{} ->
        Repo.preload(struct, [:company, :user, sale: [items: [:product, :service]]])

      _ ->
        %{}
    end
  end

  defp create_star_or_review(sale_id, contact_id, id, type, callback) do
    with sale <- get_sale(sale_id),
         true <- sale.contact_id == contact_id,
         {:ok, _item} <- find_in_items(sale.items, type, id) do
      params = %{
        "sale_id" => sale_id,
        "contact_id" => contact_id,
        "#{Atom.to_string(type)}_id" => id
      }

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

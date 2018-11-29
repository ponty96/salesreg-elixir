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
    Receipt
  ]

  @receipt_html_path "lib/sales_reg_web/templates/mailer/receipt.html.eex"

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

  def update_receipt_details(filename, receipt) do
    company = load_pdf_resource(receipt).company
    url = SalesReg.ImageUpload.url({filename, company})
    __MODULE__.update_receipt(receipt, %{pdf_url: url})
  end

  def upload_pdf(%Receipt{} = receipt) do
    receipt = load_pdf_resource(receipt)
    uniq_name = gen_pdf_uniq_name(receipt)

    {:ok, path} =
      receipt
      |> build_receipt_html()
      |> PdfGenerator.generate(filename: uniq_name)

    SalesReg.ImageUpload.store({path, receipt.company})
  end

  defp build_receipt_html(receipt) do
    receipt = load_pdf_resource(receipt)
    EEx.eval_file(@receipt_html_path, receipt: receipt)
  end

  defp gen_pdf_uniq_name(%Receipt{} = receipt) do
    receipt = load_pdf_resource(receipt)
    count = Enum.count(Repo.all(Receipt))

    "#{String.replace(receipt.company.title, " ", "-")}-receipt-#{count}"
  end

  defp load_pdf_resource(struct) do
    case struct do
      %Receipt{} ->
        Repo.preload(struct, [:company, :user, sale: [items: [:product, :service]]])

      _ ->
        %{}
    end
  end
end

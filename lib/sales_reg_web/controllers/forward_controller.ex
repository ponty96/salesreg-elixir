defmodule SalesRegWeb.ForwardController do
  use SalesRegWeb, :controller

  def forward_business(conn, %{"business_slug" => slug}) do
    redirect(conn, external: base_url(conn, slug))
  end

  def forward_product(conn, %{"business_slug" => slug, "product_slug" => product_slug}) do
    url =
      "#{base_url(conn, slug)}/store/products/#{product_slug}?#{
        get_product_query_params(product_slug)
      }"

    redirect(conn, external: url)
  end

  def forward_invoice(conn, %{"business_slug" => slug, "invoice_id" => invoice_id}) do
    url = "#{base_url(conn, slug)}/invoices/#{invoice_id}"

    redirect(conn, external: url)
  end

  def forward_bonanza(conn, %{"business_slug" => slug, "bonanza_id" => bonanza_id}) do
    url = "#{base_url(conn, slug)}/special-offers/#{bonanza_id}"

    redirect(conn, external: url)
  end

  def forward_receipt(conn, %{"business_slug" => slug, "receipt_id" => receipt_id}) do
    url = "#{base_url(conn, slug)}/receipts/#{receipt_id}"

    redirect(conn, external: url)
  end

  def forward_sale(conn, %{"business_slug" => slug, "sale_id" => receipt_id}) do
    url = "#{base_url(conn, slug)}/sales/#{receipt_id}"

    redirect(conn, external: url)
  end

  defp get_product_query_params(product_slug) do
    %{option_values: option_values} =
      product_slug
      |> Store.get_product_by_slug()
      |> Repo.preload([:option_values, option_values: [:option]])

    option_values
    |> Enum.with_index()
    |> Enum.map(fn {option_value, index} ->
      "#{option_value.option.name}=#{option_value.name}#{
        if index == Enum.count(option_values) - 1, do: "", else: "&"
      }"
    end)
    |> Enum.join("")
  end

  defp base_url(conn, slug) do
    base_domain = System.get_env("BASE_DOMAIN")
    scheme = Atom.to_string(conn.scheme)
    "#{scheme}://#{slug}.#{base_domain}"
  end
end

defmodule SalesRegWeb.ForwardController do
  use SalesRegWeb, :controller

  def forward_business(conn, %{"business_slug" => slug}) do
    redirect(conn, external: base_url(conn, slug))
  end

  def forward_product(conn, %{"business_slug" => slug, "product_slug" => product_slug}) do
    url = "#{base_url(conn, slug)}/store/products/#{product_slug}"
    redirect(conn, external: url)
  end

  defp base_url(conn, slug) do
    base_domain = System.get_env("BASE_DOMAIN")
    scheme = Atom.to_string(conn.scheme)
    "#{scheme}://#{slug}.#{base_domain}"
  end
end

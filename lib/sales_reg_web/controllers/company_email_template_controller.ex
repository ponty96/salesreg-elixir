defmodule SalesRegWeb.CompanyEmailTemplateController do
  use SalesRegWeb, :controller
  use SalesRegWeb, :context

  plug(Ueberauth)

  def update_email_template(conn, %{"id" => id, "email_template" => %{type: _type} = params}) do
    template = Theme.get_company_email_template(id)

    case Theme.update_company_email_template(template, params) do
      {:ok, _template} ->
        conn
        |> put_flash(:info, "Company Email Template updated successfully.")
        |> redirect(to: page_path(conn, :index))

      {:error, changeset} ->
        render(conn, "index.html", changeset: changeset)
    end
  end
end

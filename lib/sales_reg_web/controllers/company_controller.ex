defmodule SalesRegWeb.CompanyController do
  use SalesRegWeb, :controller
  use SalesRegWeb, :context

  plug(Ueberauth)

  def new(conn, _params) do
    changeset = Business.change_company(%Company{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"company" => params}) do
    user = conn.assigns.current_user

    case Business.create_company(user.id, atomize_keys(params)) do
      {:ok, _company} ->
        conn
        |> put_flash(:info, "Company Registered!")
        |> redirect(to: theme_path(conn, :index))

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  defp atomize_keys(params) do
    for {key, val} <- params, into: %{} do
      {String.to_atom(key), val}
    end
  end
end

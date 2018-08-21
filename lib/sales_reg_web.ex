defmodule SalesRegWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use SalesRegWeb, :controller
      use SalesRegWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: SalesRegWeb
      import Plug.Conn
      import SalesRegWeb.Router.Helpers
      import SalesRegWeb.Gettext
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/sales_reg_web/templates",
        namespace: SalesRegWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 2, view_module: 1]

      import SalesRegWeb.Router.Helpers
      import SalesRegWeb.ErrorHelpers
      import SalesRegWeb.Gettext
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import SalesRegWeb.Gettext
    end
  end

  def context do
    quote do
      import Ecto.{Query, Changeset}

      alias Ecto.Multi
      alias SalesReg.Repo
      alias SalesReg.Search
      alias SalesReg.Seed

      alias Ecto.Queryable
      SalesRegWeb.shared_aliases()
    end
  end

  defmacro shared_aliases do
    quote do
      alias Ecto.Queryable

      alias SalesReg.{
        Accounts,
        Accounts.User,
        Business,
        Business.Company,
        Business.Employee,
        Business.Branch,
        Business.Contact,
        Business.Location,
        Business.Phone,
        Business.Bank,
        Store,
        Store.Product,
        Store.Service,
        Order,
        Order.Purchase,
        Order.Item,
        Order.Sale
      }
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end

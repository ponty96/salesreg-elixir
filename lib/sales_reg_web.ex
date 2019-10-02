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
      alias SalesReg.Repo
      SalesRegWeb.shared_aliases()
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/sales_reg_web/templates",
        namespace: SalesRegWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import SalesRegWeb.Router.Helpers
      import SalesRegWeb.ErrorHelpers
      import SalesRegWeb.Gettext
      SalesRegWeb.shared_aliases()
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
      alias Ecto.Queryable
      alias Plug.Conn
      alias SalesReg.Context
      alias SalesReg.Repo
      alias SalesReg.Search
      alias SalesReg.Seed
      alias SalesRegWeb.Authentication
      alias SalesRegWeb.TokenImpl
      SalesRegWeb.shared_aliases()
    end
  end

  def graphql_context do
    quote do
      alias Ecto.Queryable
      alias SalesReg.Context
      alias SalesReg.Repo
      alias SalesReg.Search
      alias SalesReg.Seed
      alias SalesRegWeb.Authentication

      SalesRegWeb.shared_aliases()
    end
  end

  defmacro shared_aliases do
    quote do
      alias Ecto.Queryable

      alias SalesReg.Accounts
      alias SalesReg.Accounts.User

      alias SalesReg.Analytics

      alias SalesReg.Business
      alias SalesReg.Business.Bank
      alias SalesReg.Business.Branch
      alias SalesReg.Business.Company
      alias SalesReg.Business.Contact
      alias SalesReg.Business.Expense
      alias SalesReg.Business.ExpenseItem
      alias SalesReg.Business.LegalDocument
      alias SalesReg.Business.Location
      alias SalesReg.Business.Phone

      alias SalesReg.Email
      alias SalesReg.Mailer

      alias SalesReg.Notifications
      alias SalesReg.Notifications.MobileDevice
      alias SalesReg.Notifications.Notification
      alias SalesReg.Notifications.NotificationItem

      alias SalesReg.Order
      alias SalesReg.Order.Activity
      alias SalesReg.Order.DeliveryFee
      alias SalesReg.Order.Invoice
      alias SalesReg.Order.Item
      alias SalesReg.Order.Receipt
      alias SalesReg.Order.Review
      alias SalesReg.Order.Sale
      alias SalesReg.Order.Star

      alias SalesReg.SpecialOffer
      alias SalesReg.SpecialOffer.Bonanza
      alias SalesReg.SpecialOffer.BonanzaItem

      alias SalesReg.Store
      alias SalesReg.Store.Category
      alias SalesReg.Store.Product
      alias SalesReg.Store.Tag

      alias SalesReg.TaskSupervisor

      alias SalesReg.Theme
      alias SalesReg.Theme.CompanyEmailTemplate
      alias SalesReg.Theme.CompanyTemplate
      alias SalesReg.Theme.Template
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end

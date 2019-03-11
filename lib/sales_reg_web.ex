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
      alias SalesReg.Repo
      alias SalesReg.Search
      alias SalesReg.Seed
      alias SalesReg.Context
      alias SalesRegWeb.Authentication
      alias Plug.Conn
      alias SalesRegWeb.TokenImpl
      alias Ecto.Queryable
      SalesRegWeb.shared_aliases()
    end
  end

  def graphql_context do
    quote do
      alias SalesReg.Repo
      alias SalesReg.Search
      alias SalesReg.Seed
      alias SalesReg.Context
      alias SalesRegWeb.Authentication

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
        Contact,
        Business.Company,
        Business.Branch,
        Business.Contact,
        Business.Location,
        Business.Phone,
        Business.Bank,
        Business.Expense,
        Business.ExpenseItem,
        Business.LegalDocument,
        Store,
        Store.Product,
        Store.Category,
        Store.Tag,
        Order,
        Order.Item,
        Order.Sale,
        Order.Invoice,
        Order.Receipt,
        Order.Review,
        Order.Star,
        Order.Activity,
        Order.DeliveryFee,
        Store.ProductGroup,
        Store.Option,
        Store.OptionValue,
        TaskSupervisor,
        Theme,
        Theme.Template,
        Theme.CompanyTemplate,
        Theme.CompanyEmailTemplate,
        Email,
        Mailer,
        SpecialOffer,
        SpecialOffer.Bonanza,
        SpecialOffer.BonanzaItem,
        Notifications,
        Notifications.Notification,
        Notifications.NotificationItem,
        Notifications.MobileDevice
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

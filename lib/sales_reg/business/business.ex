defmodule SalesReg.Business do
  @moduledoc """
  The Business context.
  """
  use SalesRegWeb, :context
  alias Dataloader.Ecto, as: DataloaderEcto
  alias SalesReg.Mailer.YipcartToMerchants, as: YC2C

  alias SalesRegWeb.Services.Cloudfare
  alias SalesRegWeb.Services.Flutterwave
  alias SalesRegWeb.Services.Heroku

  require Logger

  use SalesReg.Context, [
    Location,
    Contact,
    Company,
    Branch,
    Expense,
    Bank,
    LegalDocument
  ]

  @default_template_slug "yc1-template"
  @email_types [
    "yc_email_before_due",
    "yc_email_early_due",
    "yc_email_late_overdue",
    "yc_email_received_order",
    "yc_email_reminder",
    "yc_payment_received",
    "yc_email_delivered_order",
    "yc_email_delivering_order",
    "yc_email_pending_delivery",
    "yc_email_pending_order"
  ]

  def create_company(user_id, company_params) do
    company_params = Map.put(company_params, :owner_id, user_id)

    with {:ok, company} <- add_company(company_params),
         branch_params <- %{
           type: "head_office",
           location: Map.get(company_params, :head_office),
           company_id: company.id
         },
         _response <- create_business_subdomain(company.slug),
         {:ok, _branch} <- add_branch(branch_params),
         [{:ok, _option} | _t] <- Store.insert_default_options(company.id),
         template <- Theme.get_template_by_slug(@default_template_slug),
         company_template_params <- %{
           template_id: template.id,
           company_id: company.id,
           user_id: user_id
         },
         {:ok, _company_template} <- Theme.add_company_template(company_template_params),
         {_int, _result} <- insert_company_email_temps(company.id),
         %Bamboo.Email{} <- YC2C.send_welcome_mail(company) do
      {:ok, company}
    else
      {:error, changeset} -> {:error, changeset}
    end
  end

  def update_company_details(id, company_params) do
    with %Company{} = company <- get_company(id),
         {:ok, company} <- update_company(company, company_params),
         branch_params <- %{
           type: "head_office",
           location: Map.get(company_params, :head_office)
         },
         {:ok, _branch} <- update_company_head_office(company.id, branch_params) do
      {:ok, company}
    else
      {:error, changeset} -> {:error, changeset}
    end
  end

  def update_company_head_office(company_id, branch_params) do
    branch = Repo.get_by(Branch, type: "head_office", company_id: company_id)
    update_branch(branch, branch_params)
  end

  def change_company(%Company{} = company) do
    Company.changeset(company, %{})
  end

  def update_company_cover_photo(%{cover_photo: _cover_photo, company_id: id} = params) do
    id
    |> Business.get_company()
    |> Business.update_company(params)
  end

  def get_company_subdomain(company) do
    base_domain =
      Application.get_env(:sales_reg, Heroku)
      |> Keyword.get(:base_domain)

    company.slug <> "." <> base_domain
  end

  def insert_company_email_temps(company_id) do
    templates =
      Enum.map(@email_types, fn type ->
        %{
          body: return_file_content(type),
          type: type,
          company_id: company_id
        }
      end)

    Repo.insert_all(CompanyEmailTemplate, templates)
  end

  def get_company_share_domain do
    System.get_env("SHORT_URL") || "https://ycartstag.me"
  end

  def get_company_share_url(company) do
    "#{get_company_share_domain()}/#{company.slug}"
  end

  def get_company_address(company) do
    company = Repo.preload(company, branches: [:location])
    location = Enum.at(company.branches, 0).location

    "#{location.street1} #{location.city} #{location.state} #{location.country}"
  end

  ## CONTACTS
  def list_company_contacts(company_id, type) do
    {:ok,
     Repo.all(
       from(
         ct in Contact,
         where: ct.company_id == ^company_id and ct.type == ^type,
         order_by: [desc: ct.updated_at]
       )
     )}
  end

  def get_contact_by_email(email) do
    Repo.get_by(Contact, email: email)
  end

  def data do
    DataloaderEcto.new(Repo, query: &query/2)
  end

  def query(queryable, _) do
    queryable
  end

  def send_registration_email(_user_id, _company) do
    {:ok, "sent"}
  end

  def create_bank(params) do
    with {:ok, :success, data} <- create_subaccount(params),
         bank_params <- update_bank_params(params, data),
         {:ok, bank} <- Business.add_bank(bank_params) do
      {:ok, bank}
    else
      {:ok, :fail, _data} ->
        Logger.debug(fn -> "The Server did perform the transaction." end)
        {:error, [%{key: "subaccount", message: "Not successful"}]}

      {:error, %Ecto.Changeset{}} = error ->
        error

      {:error, _reason} ->
        Logger.error(fn -> "An error occurred" end)
        {:error, [%{key: "subaccount", message: "Not successful"}]}
    end
  end

  def update_bank_details(bank, params) do
    with {:ok, :success, data} <- update_subaccount(params, bank.subaccount_transac_id),
         {:ok, bank} <- Business.update_bank(bank, params) do
      {:ok, bank}
    else
      {:ok, :fail, _data} ->
        Logger.debug(fn -> "The Server did perform the transaction." end)
        {:error, [%{key: "subaccount", message: "Not successful"}]}

      {:error, %Ecto.Changeset{}} = error ->
        error

      {:error, _reason} ->
        Logger.error(fn -> "An error occurred" end)
        {:error, [%{key: "subaccount", message: "Not successful"}]}
    end
  end

  def company_banks(company_id) do
    Bank
    |> where([b], b.company_id == ^company_id)
    |> Repo.all()
  end

  def list_company_tags(company_id) do
    {:ok,
     Tag
     |> where([t], t.company_id == ^company_id)
     |> Repo.all()}
  end

  def get_company_by_slug(name) do
    Company
    |> Repo.get_by(slug: name)
    |> Repo.preload([:company_template, [company_template: :template]])
  end

  def search_customers_by_name(%{company_id: company_id, name: name}) do
    Contact
    |> Context.search_schema_by_field({name, company_id}, :contact_name)
    |> Enum.filter(fn contact ->
      contact.type == "customer"
    end)
  end

  def create_expense(%{expense_items: _items} = params) do
    params
    |> put_items_amount()
    |> Business.add_expense()
  end

  def create_expense(params) do
    Business.add_expense(params)
  end

  def update_expense_details(expense, %{expense_items: _items} = params) do
    Business.update_expense(expense, put_items_amount(params))
  end

  def update_expense_details(expense, params) do
    Business.update_expense(expense, params)
  end

  # Private Functions

  # The business name is the slug of the company
  defp create_business_subdomain(business_name) do
    Task.Supervisor.start_child(TaskSupervisor, fn ->
      base_domain =
        Application.get_env(:sales_reg, Heroku)
        |> Keyword.get(:base_domain)

      hostname = String.downcase(business_name) <> "." <> base_domain

      with :ok <-
             Logger.info(fn -> "Creating new domain on heroku with hostname: #{hostname}" end),
           {:ok, :success, data} <- Heroku.create_domain(hostname),
           {:ok, :success, data} <-
             Cloudfare.create_dns_record(
               "CNAME",
               data["hostname"],
               data["cname"],
               %{"ttl" => 1}
             ) do
        {:ok, :success, data}
      else
        {:ok, :fail, data} ->
          Logger.debug(fn -> "The Server did perform the transaction: #{data["cname"]}" end)
          {:ok, :fail, data}

        {:error, reason} ->
          Logger.error(fn -> "An error occurred: #{reason}" end)
          {:error, reason}
      end
    end)
  end

  defp return_file_content(type) do
    {:ok, binary} =
      ("./lib/sales_reg_web/templates/mailer/#{type}" <> ".html.eex")
      |> Path.expand()
      |> File.read()

    binary
  end

  defp put_items_amount(params) do
    total_amount =
      params.expense_items
      |> calc_expense_amount(0)

    Map.put_new(params, :items_amount, total_amount)
  end

  defp calc_expense_amount([], 0), do: 0.0
  defp calc_expense_amount([], acc), do: Float.round(acc, 2)

  defp calc_expense_amount([h | t], acc) do
    val = fn amount ->
      {float, _} = Float.parse(amount)
      float
    end

    calc_expense_amount(t, acc + val.(h.amount))
  end

  defp create_subaccount(params) do
    company = preload_company(params.company_id)

    params
    |> construct_subaccount_params(company)
    |> Flutterwave.create_subaccount()
  end

  defp update_bank_params(params, data) do
    params
    |> Map.put(:subaccount_id, "#{data["data"]["subaccount_id"]}")
    |> Map.put(:subaccount_transac_id, "#{data["data"]["id"]}")
  end

  defp update_subaccount(params, subaccount_id) do
    company = preload_company(params.company_id)

    params
    |> construct_subaccount_params(company)
    |> Flutterwave.update_subaccount(subaccount_id)
  end

  defp preload_company(company_id) do
    Company
    |> Repo.get(company_id)
    |> Repo.preload([:phone])
  end

  defp construct_subaccount_params(params, company) do
    %{
      account_bank: params.bank_name,
      account_number: params.account_number,
      business_name: company.title,
      business_email: company.contact_email,
      business_mobile: company.phone.number
    }
  end
end

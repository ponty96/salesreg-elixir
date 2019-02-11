defmodule SalesReg.Business do
  @moduledoc """
  The Business context.
  """
  use SalesRegWeb, :context
  alias Dataloader.Ecto, as: DataloaderEcto
  alias SalesRegWeb.Services.{Heroku, Cloudfare}
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
         {:ok, company_template} <- Theme.add_company_template(company_template_params),
         {_int, _result} <- insert_company_email_temps(company.id),
         # TODO send email in task supervisor process
         %Bamboo.Email{} <- send_email(company, "yc_email_welcome_to_yc") do
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
         {:ok, branch} <- update_company_head_office(company.id, branch_params) do
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
    Business.get_company(id)
    |> Business.update_company(params)
  end

  def send_email(resource, type) do
    binary = return_file_content(type)
    Email.send_email(resource, type, binary)
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

  def get_company_share_domain() do
   System.get_env("SHORT_URL") || "https://ycartstag.me"
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
    bank_list = company_banks(params.company_id)

    case params do
      %{is_primary: true} ->
        if Enum.count(bank_list) == 0 do
          Business.add_bank(params)
        else
          update_bank_field(params.company_id)
          Business.add_bank(params)
        end

      _ ->
        if Enum.count(bank_list) == 0 do
          params
          |> Map.put(:is_primary, true)
          |> Business.add_bank()
        else
          Business.add_bank(params)
        end
    end
  end

  def update_bank_details(bank, params) do
    case params do
      %{is_primary: true} ->
        update_bank_field(params.company_id)
        Business.update_bank(bank, params)

      _ ->
        Business.update_bank(bank, params)
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
    Context.search_schema_by_field(Contact, {name, company_id}, :contact_name)
    |> Enum.filter(fn contact ->
      contact.type == "customer"
    end)
  end

  def create_expense(%{expense_items: _items} = params) do
    put_items_amount(params)
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
      Path.expand("./lib/sales_reg_web/templates/mailer/#{type}" <> ".html.eex")
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

  defp update_bank_field(company_id) do
    attrs = %{"is_primary" => false}

    Bank
    |> where([b], b.company_id == ^company_id)
    |> where([b], b.is_primary == true)
    |> Repo.one()
    |> Business.update_bank(attrs)
  end
end

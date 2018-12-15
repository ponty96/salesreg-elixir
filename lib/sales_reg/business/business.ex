defmodule SalesReg.Business do
  @moduledoc """
  The Business context.
  """
  use SalesRegWeb, :context
  alias Dataloader.Ecto, as: DataloaderEcto

  use SalesReg.Context, [
    Location,
    Contact,
    Company,
    Branch,
    Expense,
    Bank
  ]

  def create_company(user_id, company_params) do
    company_params = Map.put(company_params, :owner_id, user_id)

    with {:ok, company} <- add_company(company_params),
         branch_params <- %{
           type: "head_office",
           location: Map.get(company_params, :head_office),
           company_id: company.id
         },
         {:ok, _branch} <- add_branch(branch_params),
         [{:ok, _option} | _t] <- Store.insert_default_options(company.id) do
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

  def search_customers_by_name(%{company_id: company_id, name: name}) do
    Context.search_schema_by_field(Contact, {name, company_id}, :contact_name)
    |> Enum.filter(fn contact ->
      contact.type == "customer"
    end)
  end

  # Private Functions
  defp update_bank_field(company_id) do
    attrs = %{"is_primary" => false}

    Bank
    |> where([b], b.company_id == ^company_id)
    |> where([b], b.is_primary == true)
    |> Repo.one()
    |> Business.update_bank(attrs)
  end
end

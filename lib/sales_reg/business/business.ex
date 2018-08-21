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
    Branch
  ]

  def create_company(user_id, company_params) do
    company_params = Map.put(company_params, :owner_id, user_id)

    with {:ok, company} <- add_company(company_params),
         branch_params <- %{
           type: "head_office",
           location: Map.get(company_params, :head_office),
           company_id: company.id
         },
         {:ok, _branch} <- add_branch(branch_params) do
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

  ## CONTACTS
  def list_company_contacts(company_id, type) do
    {:ok,
     Repo.all(
       from(ct in Contact,
         where: ct.company_id == ^company_id and ct.type == ^type,
         order_by: [desc: ct.updated_at]
       )
     )}
  end

  #
  # COMPANY EMPLOYEE
  #
  def add_company_employee(company_id, employee_params) do
    employee_params = Map.put(employee_params, :employer_id, company_id)

    %Employee{}
    |> Employee.changeset(employee_params)
    |> Repo.insert()
  end

  def update_company_employee(employee_id, employee_params) do
    employee = Repo.get(Employee, employee_id)

    employee
    |> Employee.changeset(employee_params)
    |> Repo.update()
  end

  def delete_company_employee(employee_id) do
    employee_id
    |> Repo.get(Employee)
    |> Repo.delete()
  end

  def delete_all_company_employeees(company_id) do
    from(br in Employee, where: br.company_id == ^company_id)
    |> Repo.delete_all()
  end

  def all_company_employeees(company_id) do
    employeees =
      from(br in Employee, where: br.company_id == ^company_id)
      |> Repo.all()

    {:ok, employeees}
  end

  def get_company_employee(employee_id) do
    {:ok, Repo.get(Employee, employee_id)}
  end

  def data do
    DataloaderEcto.new(Repo, query: &query/2)
  end

  def query(queryable, _) do
    queryable
  end

  def send_registration_email(_user, _company) do
    {:ok, "sent"}
  end
end

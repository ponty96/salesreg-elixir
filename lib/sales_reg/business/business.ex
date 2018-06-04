defmodule SalesReg.Business do
  @moduledoc """
  The Business context.
  """
  use SalesRegWeb, :context
  alias Dataloader.Ecto, as: DataloaderEcto

  use SalesReg.Context, [
    Contact
  ]

  def create_company(user_id, company_params) do
    company_params = Map.put(company_params, :owner_id, user_id)

    with {:ok, company} <- create_company(company_params),
         branch_params <- %{type: "head_office", location: Map.get(company_params, :head_office)},
         {:ok, _branch} <- add_company_branch(company.id, branch_params) do
      {:ok, company}
    else
      {:error, changeset} -> {:error, changeset}
    end
  end

  defp create_company(company_params) do
    %Company{}
    |> Company.changeset(company_params)
    |> Repo.insert()
  end

  def update_company(id, company_params) do
    company = Repo.get(Company, id)

    company
    |> Company.changeset(company_params)
    |> Repo.update()
  end

  #
  # COMPANY BRANCH
  #

  def add_company_branch(company_id, branch_params) do
    branch_params = Map.put(branch_params, :company_id, company_id)

    %Branch{}
    |> Branch.changeset(branch_params)
    |> Repo.insert()
  end

  def update_company_branch(branch_id, branch_params) do
    branch = Repo.get(Branch, branch_id)

    branch
    |> Branch.changeset(branch_params)
    |> Repo.update()
  end

  def delete_company_branch(branch_id) do
    branch_id
    |> Repo.get(Branch)
    |> Repo.delete()
  end

  def delete_all_company_branches(company_id) do
    from(br in Branch, where: br.company_id == ^company_id)
    |> Repo.delete_all()
  end

  def all_company_branches(company_id) do
    branches =
      from(br in Branch, where: br.company_id == ^company_id)
      |> Repo.all()

    {:ok, branches}
  end

  def get_company_branch(branch_id) do
    {:ok, Repo.get(Branch, branch_id)}
  end

  #
  # COMPANY EMPLOYEE
  #
  def add_company_employee(company_id, employee_params) do
    employee_params = Map.put(employee_params, :company_id, company_id)

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

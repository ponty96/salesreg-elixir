defmodule SalesReg.Theme do
  @moduledoc """
  The Theme Context.
  """
  use SalesRegWeb, :context
  alias Dataloader.Ecto, as: DataloaderEcto
  alias SalesReg.Theme.CompanyTemplate

  use SalesReg.Context, [
    Template,
    CompanyTemplate
  ]

  def data do
    DataloaderEcto.new(Repo, query: &query/2)
  end

  def query(queryable, _) do
    queryable
  end

  def list_templates() do
    Template
    |> Repo.all()
  end

  def get_company_template_by_company_id(company_id) do
    Repo.get_by(CompanyTemplate, company_id: company_id)
  end

  def set_company_template(company_id, template_id, params \\ %{}) do
    params =
      params
      |> Map.put("template_id", template_id)
      |> Map.put("company_id", company_id)

    company_template = Repo.get_by(CompanyTemplate, company_id: company_id)

    if company_template == nil do
      Theme.add_company_template(params)
    else
      Theme.delete_company_template(company_template)
      Theme.add_company_template(params)
    end
  end

  def upsert_template(%{template: params, template_id: id}) do
    Theme.get_template(id)
    |> Theme.update_template(params)
  end

  def upsert_template(%{template: params}) do
    Theme.add_template(params)
  end

  def delete_template(%{template_id: template_id}) do
    Theme.get_template(template_id)
    |> Theme.delete_template()
  end
end

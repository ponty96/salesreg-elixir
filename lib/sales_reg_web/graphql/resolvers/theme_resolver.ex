defmodule SalesRegWeb.GraphQL.Resolvers.ThemeResolver do
  use SalesRegWeb, :context
  alias SalesReg.Theme

  def list_templates(args \\ %{}, _res) do
    {:ok, templates} = Theme.list_templates()

    templates
    |> Absinthe.Relay.Connection.from_list(pagination_args(args))
  end

  def get_company_template_by_company_id(%{company_id: company_id}, _res) do
    Theme.get_company_template_by_company_id(company_id)
  end

  def set_company_template(
        %{company_id: company_id, template_id: template_id},
        _res
      ) do
    Theme.set_company_template(company_id, ctemplate_id)
  end

  defp pagination_args(args) do
    Map.take(args, [:first, :after, :last, :before])
  end
end

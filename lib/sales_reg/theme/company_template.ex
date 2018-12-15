defmodule SalesReg.Theme.CompanyTemplate do
  use Ecto.Schema
  import Ecto.Changeset
  alias SalesReg.Repo

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @company_template_status ["active", "inactive"]

  schema "company_templates" do
    field(:status, :string, default: "active")

    belongs_to(:template, SalesReg.Theme.Template)
    belongs_to(:user, SalesReg.Accounts.User)
    belongs_to(:company, SalesReg.Business.Company)

    timestamps()
  end

  @required_field [:status, :template_id, :company_id]
  @optional_fields [:user_id]

  def changeset(company_template, attrs) do
    company_template
    |> cast(attrs, @required_field ++ @optional_fields)
    |> validate_required(@required_field)
    |> validate_inclusion(:status, @company_template_status)
    |> unique_constraint(:company_id)
    |> foreign_key_constraint(:template_id)
  end

  def delete_changeset(company_template) do
    company_template
    |> Repo.preload(:template)
    |> cast(%{}, [])
    |> foreign_key_constraint(:template_id)
  end
end

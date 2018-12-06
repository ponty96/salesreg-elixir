defmodule SalesReg.Themes.CompanyTemplate do
	use Ecto.Schema
	import Ecto.Changeset

	@primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

	schema "company_templates" do
    field(:status, :string)
		
		belongs_to(:template, SalesReg.Themes.Template)
    belongs_to(:user, SalesReg.Accounts.User)
    belongs_to(:company, SalesReg.Business.Company)
		
		timestamps()
	end

	@required_fields [
    :status,
    :template_id,
    :user_id,
    :company_id
	]
	
	def changeset(template, attrs) do
		template
		|> cast(attrs, @required_fields)
		|> validate_required(@required_fields)
	end
end
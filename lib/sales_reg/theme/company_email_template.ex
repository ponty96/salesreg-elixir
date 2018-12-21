defmodule SalesReg.Theme.CompanyEmailTemplate do
    use Ecto.Schema
    import Ecto.Changeset
  
    @primary_key {:id, :binary_id, autogenerate: true}
    @foreign_key_type :binary_id
  
    @email_types [
			"yc_email_before_due", 
			"yc_email_early_due", 
			"yc_email_late_overdue", 
      "yc_email_received_order",
      "yc_email_reminder",
      "yc_email_restock",
      "yc_email_welcome_to_yc",
      "yc_payment_received"
		]

    schema "company_email_templates" do
      field(:body, :string)
      field(:type,  :string)
			
			belongs_to(:sale, SalesReg.Order.Sale)
      belongs_to(:company, SalesReg.Business.Company)
    end
  
    @required_fields [
      :body,
			:type,
      :company_id
		]
		
		@optional_fields [
			:sale_id
		]
  
    def changeset(company_email_template, attrs) do
      company_email_template
      |> cast(attrs, @required_fields)
			|> validate_required(@required_fields)
			|> validate_inclusion(:type, @email_types)
			|> unique_constraint(
				:type,
				name: :company_email_templates_type_company_id_index
			)
    end
  end
  
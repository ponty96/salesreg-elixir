defmodule SalesReg.Theme.CompanyEmailTemplate do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @email_types [
    "invoice_pre_due_date",
    "invoice_on_due_date",
    "invoice_post_due_date",
    "invoice_on_order",
    "order_receipt"
  ]

  schema "company_email_templates" do
    field(:message, :string)
    field(:type, :string)

    belongs_to(:sale, SalesReg.Order.Sale)
    belongs_to(:company, SalesReg.Business.Company)

    timestamps()
  end

  @required_fields [
    :message,
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

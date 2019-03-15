defmodule SalesReg.Business.LegalDocument do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @legal_document_type ["POLICY", "TERMS", "INFORMATION"]

  schema "legal_documents" do
    field(:name, :string)
    field(:type, :string)
    field(:content, :string)
    field(:pdf_url, :string)

    belongs_to(:company, SalesReg.Business.Company)

    timestamps()
  end

  @required_field [:name, :type, :company_id]
  @optional_field [:pdf_url, :content]

  def changeset(legal_document, attrs) do
    legal_document
    |> cast(attrs, @required_field ++ @optional_field)
    |> validate_required(@required_field)
    |> validate_inclusion(:type, @legal_document_type)
  end

  def delete_changeset(legal_document) do
    legal_document
    |> cast(%{}, [])
  end
end

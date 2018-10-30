defmodule SalesReg.Business.Company do
  use Ecto.Schema
  import Ecto.Changeset
  alias SalesReg.Repo

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  alias SalesReg.Business.{Branch, Contact}

  schema "companies" do
    field(:about, :string)
    field(:contact_email, :string)
    field(:currency, :string)
    field(:title, :string)
    field(:category, :string)
    field(:description, :string)
    field(:logo, :string)
    field(:cover_photo, :string)
    field(:upload_successful?, :map, virtual: true)

    belongs_to(:owner, SalesReg.Accounts.User)
    has_many(:branches, Branch)
    has_many(:contacts, Contact)
    has_many(:purchases, SalesReg.Order.Purchase)
    has_one(:phone, SalesReg.Business.Phone, on_replace: :delete)
    has_one(:bank, SalesReg.Business.Bank, on_replace: :delete)
    timestamps()
  end

  @required_fields [:title, :contact_email, :owner_id, :category]
  @optional_fields [:about, :currency, :description, :logo, :cover_photo, :upload_successful?]
  @doc false
  def changeset(company, attrs) do
    company
    |> Repo.preload([:phone, :bank])
    |> change(attrs)
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> unique_constraint(:owner_id, message: "Sorry, but you already have a business with us")
    |> cast_assoc(:phone)
    |> validate_required(@required_fields)
    # |> cast_assoc(:branches)
    |> validate_category()
    |> cast_assoc(:bank)
    |> ensure_image_upload()
  end

  def validate_category(changeset) do
    case get_field(changeset, :category) do
      "product" -> changeset
      "service" -> changeset
      "product_service" -> changeset
      _ -> add_error(changeset, :category, "Invalid category")
    end
  end

  def ensure_image_upload(changeset) do
    case changeset.changes do
      %{upload_successful?: %{cover_photo: false, logo: false}} ->
        add_error(changeset, :cover_photo, "Unable to upload cover photo")
        |> add_error(:logo, "Unable to upload logo")

      %{upload_successful?: %{cover_photo: false}} ->
        add_error(changeset, :cover_photo, "Unable to upload cover photo")

      %{upload_successful?: %{logo: false}} ->
        add_error(changeset, :logo, "Unable to upload logo")

      _ ->
        changeset
    end
  end
end

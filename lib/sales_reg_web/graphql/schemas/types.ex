defmodule SalesRegWeb.GraphQL.Schemas.DataTypes do
  @moduledoc """
  	Module contains all GraphQL Object Types
  """

  use Absinthe.Schema.Notation
  use Absinthe.Ecto, repo: SalesReg.Repo
  use SalesRegWeb, :context
  import Absinthe.Resolution.Helpers

  alias SalesReg.Accounts.User
  alias Ecto.UUID
  alias Absinthe.Type.Field

  import_types(Absinthe.Type.Custom)

  @desc """
    User field type
  """

  object :user do
    field(:id, :uuid)
    field(:date_of_birth, :string)
    field(:email, non_null(:string))
    field(:first_name, :string)
    field(:gender, :string)
    field(:last_name, :string)
    field(:profile_picture, :string)

    field(:inserted_at, :naive_datetime)
    field(:updated_at, :naive_datetime)
  end

  @desc """
    Company field type
  """
  object :company do
    field(:about, :string)
    field(:contact_email, :string)
    field(:title, :string)

    field(:employees, list_of(:employee), resolve: dataloader(SalesReg.Business, :employees))
    field(:branches, list_of(:branch), resolve: dataloader(SalesReg.Business, :branches))

    field(:owner, :user, resolve: dataloader(SalesReg.Accounts, :owner))
  end

  @desc """
    Branch field type
  """
  object :branch do
    field(:type, :string)

    field(:company, :company, resolve: dataloader(SalesReg.Business, :company))
    field(:employees, list_of(:employee), resolve: dataloader(SalesReg.Business, :employees))
    field(:location, :location, resolve: dataloader(SalesReg.Business, :location))
  end

  @desc """
    Employee field type
  """
  object :employee do
    field(:person, :user, resolve: dataloader(SalesReg.Accounts, :person))

    field(:employer, :company, resolve: dataloader(SalesReg.Business, :employer))
  end

  @desc """
    Location field type
  """
  object :location do
    field(:city, :string)
    field(:country, :string)
    field(:lat, :string)
    field(:long, :string)
    field(:state, :string)
    field(:street1, :string)
    field(:street2, :string)
  end

  @desc """
    Consistent Type for Mutation Response
  """
  object :mutation_response do
    field(:success, non_null(:boolean))
    field(:field_errors, list_of(:error))
    field(:data, :mutated_data)
  end

  union :mutated_data do
    description("A mutated data")

    types([:user, :authorization, :company, :employee, :branch])

    resolve_type(fn
      %User{}, _ -> :user
      %Company{}, _ -> :company
      %Employee{}, _ -> :employee
      %Branch{}, _ -> :branch
      %{user: %User{}}, _ -> :authorization
    end)
  end

  object :error do
    field(:message, :string)
    field(:key, non_null(:string))
  end

  object :authorization do
    field(:jwt, non_null(:string))
    field(:user, non_null(:user))
  end

  @desc "sorts the order from either ASC or DESC"
  enum :gender do
    value(:male)
    value(:female)
  end

  @desc "UUID is a scalar macro that checks if id is a valid uuid"
  scalar :uuid do
    parse(fn input ->
      with %Absinthe.Blueprint.Input.String{value: value} <- input,
           {:ok, uuid} <- UUID.cast(value) do
        {:ok, uuid}
      else
        _ ->
          :error
      end
    end)

    serialize(&check_uuid/1)
  end

  def check_uuid(uuid) do
    case UUID.cast(uuid) do
      {:ok, uuid} -> uuid
      _ -> :error
    end
  end

  #
  # INPUT OBJECTS
  #
  input_object :user_input do
    field(:date_of_birth, :string)
    field(:email, non_null(:string))
    field(:first_name, non_null(:string))
    field(:gender, non_null(:gender))
    field(:last_name, non_null(:string))
    field(:password, non_null(:string))
    field(:password_confirmation, non_null(:string))
    field(:profile_picture, :string)
  end

  input_object :company_input do
    field(:title, non_null(:string))
    field(:about, non_null(:string))
    field(:contact_email, non_null(:string))
    field(:head_office, non_null(:location_input))
  end

  input_object :branch_input do
    field(:type, :string)
    field(:company_id, non_null(:uuid))
    field(:location, non_null(:location_input))
  end

  input_object :location_input do
    field(:city, non_null(:string))
    field(:country, non_null(:string))
    field(:lat, :string)
    field(:long, :string)
    field(:state, non_null(:string))
    field(:street1, non_null(:string))
    field(:street2, :string)
  end
end

defmodule SalesReg.Business do
  @moduledoc """
  The Business context.
  """
  use SalesRegWeb, :context
  alias Dataloader.Ecto, as: DataloaderEcto
  alias SalesReg.ImageUpload

  use SalesReg.Context, [
    Location,
    Contact,
    Company,
    Branch,
    Expense
  ]

  def create_company(user_id, company_params) do
    company_params = Map.put(company_params, :owner_id, user_id)
    with {:ok, company} <- add_company(company_params),
         branch_params <- %{
           type: "head_office",
           location: Map.get(company_params, :head_office),
           company_id: company.id
         },
         {:ok, _branch} <- add_branch(branch_params) do
      {:ok, company}
    else
      {:error, changeset} -> {:error, changeset}
    end
  end

  def update_company_details(id, company_params) do
    new_params = gen_new_company_params(company_params)
    with %Company{} = company <- get_company(id),
         {:ok, company} <- update_company(company, new_params),
         branch_params <- %{
           type: "head_office",
           location: Map.get(new_params, :head_office)
         },
         {:ok, branch} <- update_company_head_office(company.id, branch_params) do
      {:ok, company}
    else
      {:error, changeset} -> {:error, changeset}
    end
  end

  def update_company_head_office(company_id, branch_params) do
    branch = Repo.get_by(Branch, type: "head_office", company_id: company_id)
    update_branch(branch, branch_params)
  end

  ## CONTACTS
  def list_company_contacts(company_id, type) do
    {:ok,
     Repo.all(
       from(
         ct in Contact,
         where: ct.company_id == ^company_id and ct.type == ^type,
         order_by: [desc: ct.updated_at]
       )
     )}
  end

  def data do
    DataloaderEcto.new(Repo, query: &query/2)
  end

  def query(queryable, _) do
    queryable
  end

  def send_registration_email(_user_id, _company) do
    {:ok, "sent"}
  end

  ### Private functions
  defp gen_new_company_params(company_params) do
    case company_params do
      %{cover_photo: cover_photo, logo: logo} ->
        cover_photo = ImageUpload.upload_image(cover_photo)
        logo = ImageUpload.upload_image(logo)

        build_params(cover_photo, logo, company_params)
      
      %{cover_photo: cover_photo} ->
        cover_photo = ImageUpload.upload_image(cover_photo)
        build_params({:cover_photo, cover_photo}, company_params)

      %{logo: logo} ->
        logo = ImageUpload.upload_image(logo)
        build_params({:logo, logo}, company_params)

      _ ->
        company_params
    end
  end

  #term in this case is the filename
  defp build_params({:logo, term}, params) do
    if is_binary(term) do
      params
      |> Map.put(:logo, term)
      |> Map.put_new(:upload_successful?, %{logo: true})
    else
      params
      |> Map.put_new(:upload_successful?, %{logo: false})
    end
  end

  defp build_params({:cover_photo, term}, params) do
    IO.inspect term, label: "term"
    IO.inspect params, label: "params"
    if is_binary(term) do
      params
      |> Map.put(:cover_photo, term)
      |> Map.put_new(:upload_successful?, %{cover_photo: true})
    else
      params
      |> Map.put_new(:upload_successful?, %{cover_photo: false})
    end
  end

  defp build_params(:error, :error, params) do
    params
    |> Map.put_new(:upload_successful?, %{cover_photo: false, logo: false})
  end

  defp build_params(_cover_photo, :error, params) do
    params
    |> Map.put_new(:upload_successful?, %{cover_photo: true, logo: false})
  end

  defp build_params(:error, _logo, params) do
    params
    |> Map.put_new(:upload_successful?, %{cover_photo: false, logo: true})
  end

  defp build_params(cover_photo, logo, params) do
    %{
      params |
      cover_photo: cover_photo,
      logo: logo
    }
    |> Map.put_new(:upload_successful?, %{cover_photo: true, logo: true})
  end
end

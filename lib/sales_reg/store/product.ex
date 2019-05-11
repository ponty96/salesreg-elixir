defmodule SalesReg.Store.Product do
  @moduledoc """
  Product Schema Module
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias SalesReg.Base
  alias SalesReg.Business
  alias SalesReg.Repo
  alias SalesReg.Store
  alias SalesReg.Store.Category

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "products" do
    field(:description, :string)
    field(:name, :string)
    field(:sku, :integer)
    field(:minimum_sku, :integer)
    field(:cost_price, :decimal)
    field(:price, :decimal)
    field(:featured_image, :string)
    field(:images, {:array, :string})
    field(:is_featured, :boolean)
    field(:is_top_rated_by_merchant, :boolean)

    field(:slug, :string)
    field(:title, :string, virtual: true)

    belongs_to(:company, SalesReg.Business.Company)
    belongs_to(:user, SalesReg.Accounts.User)

    has_many(:items, SalesReg.Order.Item)
    has_many(:reviews, SalesReg.Order.Review)
    has_many(:stars, SalesReg.Order.Star)

    many_to_many(
      :categories,
      Category,
      join_through: "products_categories",
      on_replace: :delete
    )

    many_to_many(:tags, Store.Tag,
      join_through: "products_tags",
      on_replace: :delete
    )

    has_many(:option_values, Store.OptionValue, on_replace: :delete)

    belongs_to(:product_group, Store.ProductGroup)

    timestamps()
  end

  @fields [
    :description,
    :images,
    :is_featured,
    :is_top_rated_by_merchant,
    :name,
    :slug,
    :title
  ]

  @required_fields [
    :price,
    :company_id,
    :user_id,
    :sku,
    :minimum_sku,
    :featured_image,
    :product_group_id
  ]

  @number_fields [:sku, :minimum_sku, :cost_price, :price]

  @doc false
  def changeset(product, attrs) do
    new_attrs =
      attrs
      |> Base.transform_string_keys_to_numbers([:price, :cost_price])
      |> Base.convert_string_keys_integer([:sku, :minimum_sku])

    product
    |> Repo.preload(:categories)
    |> Repo.preload(:tags)
    |> Repo.preload(:option_values)
    |> cast(new_attrs, @fields ++ @required_fields)
    |> validate_required(@required_fields)
    |> assoc_constraint(:company)
    |> assoc_constraint(:user)
    |> put_assoc(:categories, Store.load_categories(attrs))
    |> put_assoc(:tags, Store.load_tags(attrs))
    |> cast_assoc(:option_values)
    |> no_assoc_constraint(:items, message: "This product is still associated with sales")
    |> add_product_slug(attrs)
    |> unique_constraint(:slug)
    |> Base.validate_changeset_number_values(@number_fields)
  end

  @doc false
  def delete_changeset(product) do
    product
    |> Repo.preload(:categories)
    |> Repo.preload(:tags)
    |> Repo.preload(:items)
    |> cast(%{}, [])
    |> no_assoc_constraint(:items, message: "This product is still associated with sales")
  end

  # get product name
  def get_product_name(product) do
    product = Repo.preload(product, [:product_group, :option_values])

    case product.option_values do
      [] ->
        product.product_group.title

      _ ->
        "#{product.product_group.title} (#{
          product.option_values |> Enum.map(&(&1.name || "?")) |> Enum.join(" ")
        })"
    end
  end

  # get product name
  def product_name_based_on_visual_options(product) do
    product = Repo.preload(product, [:product_group, option_values: [:option]])

    case product.option_values do
      [] ->
        product.product_group.title

      _ ->
        "#{product.product_group.title} #{visual_option_values_names(product.option_values)}"
    end
  end

  def get_product_share_link(product) do
    product = Repo.preload(product, [:company])
    "#{Business.get_company_share_url(product.company.slug)}/store/products/#{product.slug}"
  end

  defp add_product_slug(changeset, attrs) do
    title = attrs |> Map.get(:title) |> String.split(" ") |> Enum.join("-")

    hash_from_product_grp_uuid = attrs |> Map.get(:product_group_id) |> hash_from_product_grp_uuid

    option_values = attrs |> Map.get(:option_values)

    string_representative_of_option_values =
      case option_values do
        [] ->
          "#{title}-#{hash_from_product_grp_uuid}"

        _ ->
          "#{title}-#{
            option_values
            |> Enum.map(&(remove_space(&1.name) || ""))
            |> Enum.join("-")
          }-#{hash_from_product_grp_uuid}"
      end

    slug =
      string_representative_of_option_values
      |> String.downcase()
      |> URI.encode()

    put_change(changeset, :slug, slug)
  end

  defp hash_from_product_grp_uuid(id) do
    id
    |> String.split("-")
    |> List.last()
  end

  defp remove_space(string) do
    string |> String.split(" ") |> Enum.join("-")
  end

  defp visual_option_values_names(option_values) do
    visual_option_values =
      option_values
      |> Enum.map(fn option_value ->
        if option_value.option.is_visual == "yes" do
          option_value.name
        else
          nil
        end
      end)

    # if Enum.at(visual_option_values, 0) == nil,
    #   do: "",
    #   else: "(#{visual_option_values |> Enum.join(" ")})"
    "(#{visual_option_values |> Enum.join(" ")})"
  end
end

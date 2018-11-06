defmodule SalesReg.Store do
  @moduledoc """
  The Store context.
  """
  use SalesRegWeb, :context
  alias Dataloader.Ecto, as: DataloaderEcto

  use SalesReg.Context, [
    Product,
    Service,
    Category,
    Tag,
    ProductGroup,
    Option,
    OptionValue
  ]

  def data do
    DataloaderEcto.new(Repo, query: &query/2)
  end

  def query(queryable, _) do
    queryable
  end

  def insert_default_options(company_id) do
    [
      %{name: "Size", company_id: company_id},
      %{name: "Color", company_id: company_id},
      %{name: "Weight", company_id: company_id},
      %{name: "Height", company_id: company_id}
    ]
    |> Enum.map(&Repo.insert(Option.changeset(%Option{}, &1)))
  end

  def load_categories(%{"categories" => categories}) do
    load_categories(%{categories: categories})
  end

  def load_categories(%{categories: []}), do: []

  def load_categories(%{categories: categories_ids}) do
    Repo.all(
      from(c in Category,
        where: c.id in ^categories_ids
      )
    )
  end

  def load_tags(%{"tags" => tag_names, "company_id" => company_id}) do
    gen_company_tags(tag_names, [], company_id)
  end

  def load_tags(%{tags: tag_names, company_id: company_id}) do
    gen_company_tags(tag_names, [], company_id)
  end

  defp gen_company_tags([], acc, _company_id) do
    acc
  end

  defp gen_company_tags([tag_name | tail], acc, company_id) do
    gen_company_tags(tail, acc ++ [tag_struct(tag_name, company_id)], company_id)
  end

  defp tag_struct(tag_name, company_id) do
    tag =
      Tag
      |> where([t], t.name == ^tag_name)
      |> where([t], t.company_id == ^company_id)
      |> Repo.one()

    case tag do
      %Tag{} ->
        tag

      _ ->
        tag_params = %{
          name: tag_name,
          company_id: company_id
        }

        {:ok, tag} = Store.add_tag(tag_params)
        tag
    end
  end

  # PRODUCT INVENTORY
  def update_product_inventory(:increment, order_items) when is_list(order_items) do
    Enum.map(order_items, fn order_item ->
      if order_item.product_id do
        increment_product_sku(order_item.product_id, order_item.quantity)
      end

      order_item
    end)
  end

  def update_product_inventory(:decrement, order_items) when is_list(order_items) do
    Enum.map(order_items, fn order_item ->
      if order_item.product_id do
        decrement_product_sku(order_item.product_id, order_item.quantity)
      end

      order_item
    end)
  end

  defp increment_product_sku(product_id, quantity) do
    product = get_product(product_id)
    quantity = String.to_integer(quantity)
    product_sku = String.to_integer(product.sku)
    update_product(product, %{"sku" => "#{quantity + product_sku}"})
  end

  defp decrement_product_sku(product_id, quantity) do
    product = get_product(product_id)
    quantity = String.to_integer(quantity)
    product_sku = String.to_integer(product.sku)

    update_product(product, %{"sku" => "#{product_sku - quantity}"})
  end

  # PRODUCT VARIANT

  # EXPECTED PRODUCT PARAMS
  # product_params
  # %{
  #   product_group_id: nil,
  #   product_group_title: "",
  #   product: %{
  #     id: ""
  #     decription: "",
  #     featured_image: "",
  #     name: "",
  #     sku: "",
  #     minimum_sku: "",
  #     selling_price: "",
  #     images: [],
  #     option_values: [
  #     %{
  #       option_id: "ffddf43334", # basically the ID of the option
  #       name: "XL"
  #     },
  #     %{option_id: "ddeyu84djd09393d", name: "Red"}
  #   ]
  #   },
  # }

  # create new product with no options
  # 1 create product group
  # 2 create product, with product_group association
  def create_product(
        %{
          product_group_title: product_group_title,
          product: %{option_values: []}
        } = params
      ) do
    product_params = Map.get(params, :product)

    product_grp_params = %{
      "title" => product_group_title,
      "option_ids" => [],
      "company_id" => params.company_id
    }

    opts =
      Multi.new()
      |> Multi.insert(:insert_product_grp, product_group_changeset(product_grp_params))
      |> Multi.insert(
        :product,
        fn %{insert_product_grp: product_grp} ->
          product_params =
            product_params
            |> Map.put(:product_group_id, product_grp.id)

          Product.changeset(%Product{}, product_params)
        end
      )

    case Repo.transaction(opts) do
      {:ok, %{product: product}} -> {:ok, product}
      {:error, _failed_operation, _failed_value, changeset} -> {:error, changeset}
    end
  end

  # create new product from existing product group
  def create_product(%{product_group_id: id} = params) do
    # preload and get the current options associated with the product group
    %ProductGroup{options: current_associated_options} = product_grp = get_product_grp(id)
    add_product_to_existing(current_associated_options, params, product_grp)
  end

  # create new product with options and no existing product group
  # 1 create a product_group, add options association
  # 2 insert product, with option values association and product_group
  def create_product(%{product_group_title: product_group_title} = params) do
    options_values =
      params
      |> Map.get(:product)
      |> Map.get(:option_values, [])

    option_ids = get_option_ids_from_option_values(options_values)
    product_params = Map.get(params, :product)

    product_grp_params = %{
      "title" => product_group_title,
      "option_ids" => option_ids,
      "company_id" => params.company_id
    }

    opts =
      Multi.new()
      |> Multi.insert(
        :insert_product_grp,
        product_group_changeset(product_grp_params)
      )
      |> Multi.insert(
        :product,
        fn %{insert_product_grp: product_grp} ->
          product_params =
            product_params
            |> Map.put(:product_group_id, product_grp.id)

          Product.changeset(%Product{}, product_params)
        end
      )

    case Repo.transaction(opts) do
      {:ok, %{product: product}} ->
        {:ok, product}

      {:error, _failed_operation, failed_value, _changeset} ->
        {:error, failed_value}
    end
  end

  ## if the product group doesn't have options already,
  ##     1 update product group options association
  ##     2 update product with option values association
  defp add_product_to_existing([], params, product_grp) do
    # get the options from params
    options_values =
      params
      |> Map.get(:product)
      |> Map.get(:option_values, [])

    new_option_ids = get_option_ids_from_option_values(options_values)

    product_params = Map.get(params, :product)

    product_grp_params = %{
      "title" => Map.get(params, :product_group_title),
      "option_ids" => new_option_ids,
      "company_id" => params.company_id
    }

    opts =
      Multi.new()
      |> Multi.insert(
        :insert_product_grp,
        product_group_changeset(product_grp, product_grp_params)
      )
      |> Multi.run(:get_product, fn _repo ->
        product_id = Map.get(product_params, :id)
        Repo.get!(Product, product_id)
      end)
      |> Multi.update(
        :product,
        fn %{insert_product_grp: product_grp, get_product: product} ->
          product_params =
            product_params
            |> Map.put(:product_group_id, product_grp.id)

          Product.changeset(product, product_params)
        end
      )

    case Repo.transaction(opts) do
      {:ok, %{product: product}} -> {:ok, product}
      {:error, _failed_operation, _failed_value, changeset} -> {:error, changeset}
    end
  end

  #  if the product group has options already, we create a new product
  #      1 insert the product, with option values association
  defp add_product_to_existing(_options, params, product_grp) do
    product_params =
      params
      |> Map.get(:product)
      |> Map.put(:product_group_id, product_grp.id)

    add_product(product_params)
  end

  # update product details -> use context

  # update product group options -> use context
  def update_product_group_options(%{id: id, options: new_option_ids}) do
    # preload and get the current options associated with the product group
    %ProductGroup{options: current_associated_options} = product_grp = get_product_grp(id)

    product_grp_params = %{
      "option_ids" => new_option_ids
    }

    # delete irrelevant option values associated with options disconnected from the product group
    option_values_to_delete =
      current_associated_options
      |> compare_and_get_disconnected_options(new_option_ids)
      |> option_values_of_disconnected_options()

    opts =
      Multi.new()
      |> Multi.update(
        :update_product_grp,
        product_group_changeset(product_grp, product_grp_params)
      )
      |> Multi.delete_all(:delete_option_values, option_values_to_delete)

    case Repo.transaction(opts) do
      {:ok, %{update_product_grp: update_product_grp}} -> {:ok, update_product_grp}
      {:error, _failed_operation, _failed_value, changeset} -> {:error, changeset}
    end
  end

  defp product_group_changeset(%ProductGroup{} = schema, params) do
    ProductGroup.changeset(schema, params)
  end

  defp product_group_changeset(params) do
    ProductGroup.changeset(%ProductGroup{}, params)
  end

  def load_product_grp_options(%{"option_ids" => []}), do: []

  def load_product_grp_options(%{"option_ids" => option_ids}) do
    Repo.all(from(opt in Option, where: opt.id in ^option_ids))
  end

  defp get_option_ids_from_option_values([]), do: []

  defp get_option_ids_from_option_values(options_values) do
    Enum.map(options_values, & &1.option_id)
  end

  defp get_product_grp(id), do: get_product_group(id) |> Repo.preload(:options)

  defp compare_and_get_disconnected_options([], _new_options_ids), do: []

  defp compare_and_get_disconnected_options(current_options_structs, new_options_ids) do
    options_ids = Enum.map(current_options_structs, & &1.id)
    MapSet.difference(MapSet.new(options_ids), MapSet.new(new_options_ids))
  end

  defp option_values_of_disconnected_options(options_ids) do
    from(option_value in OptionValue, where: option_value.option_id in ^options_ids)
  end
end

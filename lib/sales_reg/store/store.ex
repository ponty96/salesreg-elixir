defmodule SalesReg.Store do
  @moduledoc """
  The Store context.
  """
  use SalesRegWeb, :context
  alias Dataloader.Ecto, as: DataloaderEcto
  alias SalesReg.ImageUpload

  use SalesReg.Context, [
    Product,
    Service
  ]

  def data do
    DataloaderEcto.new(Repo, query: &query/2)
  end

  def query(queryable, _) do
    queryable
  end

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
    product_stock_quantity = String.to_integer(product.stock_quantity)
    update_product(product, %{"stock_quantity" => "#{quantity + product_stock_quantity}"})
  end

  defp decrement_product_sku(product_id, quantity) do
    product = get_product(product_id)
    quantity = String.to_integer(quantity)
    product_stock_quantity = String.to_integer(product.stock_quantity)

    update_product(product, %{"stock_quantity" => "#{product_stock_quantity - quantity}"})
  end

  def create_service(params) do
    case params do
      %{images: images} ->
        image_list = images
        |> uploaded_image_list()
    
        new_params = build_params(params, image_list)
        Store.add_service(new_params)

      _ ->
        Store.add_service(params)
    end
  end

  def update_service(service_id, params) do
    case params do
      %{images: images} ->
        service = Store.get_service(service_id)
        image_list = images
          |> uploaded_image_list()
          |> build_image_list(service) 
    
        new_params = build_params(params, image_list)
        Store.update_service(service_id, new_params)

      _ ->
        Store.update_service(service_id, params)
    end
    
  end

  def create_product(params) do
    case params do
      %{images: images} ->
        image_list = images
        |> uploaded_image_list()
  
        new_params = build_params(params, image_list)
        Store.add_product(new_params)
      
      _ -> 
        Store.add_product(params)
    end
  end

  def update_product(product_id, params) do
    case params do
      %{images: images} ->
        product = Store.get_product(product_id)
        image_list = images
        |> uploaded_image_list()
        |> build_image_list(product) 

        new_params = build_params(params, image_list)
        Store.update_product(product_id, new_params)
      
      _ -> 
        Store.update_product(product_id, params)
    end
  end

  defp build_image_list(images, schema) do
    images ++ schema.images
    |> Enum.uniq()
  end

  defp uploaded_image_list(images) do
    images
    |> Enum.map(fn(binary) ->
      ImageUpload.upload_image(binary)
    end)
    |> Enum.filter(fn(term) -> 
      is_binary(term) 
    end)
  end

  defp build_params(params, images) do
    %{params | images: images}
  end
end

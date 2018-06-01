defmodule SalesReg.StoreTest do
  use SalesReg.DataCase

  alias SalesReg.Store

  describe "products" do
    alias SalesReg.Store.Product

    @valid_attrs %{description: "some description", image: "some image", name: "some name", pack_quantity: "some pack_quantity", price_per_pack: "some price_per_pack", selling_price: "some selling_price", unit_quantity: "some unit_quantity"}
    @update_attrs %{description: "some updated description", image: "some updated image", name: "some updated name", pack_quantity: "some updated pack_quantity", price_per_pack: "some updated price_per_pack", selling_price: "some updated selling_price", unit_quantity: "some updated unit_quantity"}
    @invalid_attrs %{description: nil, image: nil, name: nil, pack_quantity: nil, price_per_pack: nil, selling_price: nil, unit_quantity: nil}

    def product_fixture(attrs \\ %{}) do
      {:ok, product} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Store.create_product()

      product
    end

    test "list_products/0 returns all products" do
      product = product_fixture()
      assert Store.list_products() == [product]
    end

    test "get_product!/1 returns the product with given id" do
      product = product_fixture()
      assert Store.get_product!(product.id) == product
    end

    test "create_product/1 with valid data creates a product" do
      assert {:ok, %Product{} = product} = Store.create_product(@valid_attrs)
      assert product.description == "some description"
      assert product.image == "some image"
      assert product.name == "some name"
      assert product.pack_quantity == "some pack_quantity"
      assert product.price_per_pack == "some price_per_pack"
      assert product.selling_price == "some selling_price"
      assert product.unit_quantity == "some unit_quantity"
    end

    test "create_product/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Store.create_product(@invalid_attrs)
    end

    test "update_product/2 with valid data updates the product" do
      product = product_fixture()
      assert {:ok, product} = Store.update_product(product, @update_attrs)
      assert %Product{} = product
      assert product.description == "some updated description"
      assert product.image == "some updated image"
      assert product.name == "some updated name"
      assert product.pack_quantity == "some updated pack_quantity"
      assert product.price_per_pack == "some updated price_per_pack"
      assert product.selling_price == "some updated selling_price"
      assert product.unit_quantity == "some updated unit_quantity"
    end

    test "update_product/2 with invalid data returns error changeset" do
      product = product_fixture()
      assert {:error, %Ecto.Changeset{}} = Store.update_product(product, @invalid_attrs)
      assert product == Store.get_product!(product.id)
    end

    test "delete_product/1 deletes the product" do
      product = product_fixture()
      assert {:ok, %Product{}} = Store.delete_product(product)
      assert_raise Ecto.NoResultsError, fn -> Store.get_product!(product.id) end
    end

    test "change_product/1 returns a product changeset" do
      product = product_fixture()
      assert %Ecto.Changeset{} = Store.change_product(product)
    end
  end

  describe "services" do
    alias SalesReg.Store.Service

    @valid_attrs %{description: "some description", name: "some name", price: "some price"}
    @update_attrs %{description: "some updated description", name: "some updated name", price: "some updated price"}
    @invalid_attrs %{description: nil, name: nil, price: nil}

    def service_fixture(attrs \\ %{}) do
      {:ok, service} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Store.create_service()

      service
    end

    test "list_services/0 returns all services" do
      service = service_fixture()
      assert Store.list_services() == [service]
    end

    test "get_service!/1 returns the service with given id" do
      service = service_fixture()
      assert Store.get_service!(service.id) == service
    end

    test "create_service/1 with valid data creates a service" do
      assert {:ok, %Service{} = service} = Store.create_service(@valid_attrs)
      assert service.description == "some description"
      assert service.name == "some name"
      assert service.price == "some price"
    end

    test "create_service/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Store.create_service(@invalid_attrs)
    end

    test "update_service/2 with valid data updates the service" do
      service = service_fixture()
      assert {:ok, service} = Store.update_service(service, @update_attrs)
      assert %Service{} = service
      assert service.description == "some updated description"
      assert service.name == "some updated name"
      assert service.price == "some updated price"
    end

    test "update_service/2 with invalid data returns error changeset" do
      service = service_fixture()
      assert {:error, %Ecto.Changeset{}} = Store.update_service(service, @invalid_attrs)
      assert service == Store.get_service!(service.id)
    end

    test "delete_service/1 deletes the service" do
      service = service_fixture()
      assert {:ok, %Service{}} = Store.delete_service(service)
      assert_raise Ecto.NoResultsError, fn -> Store.get_service!(service.id) end
    end

    test "change_service/1 returns a service changeset" do
      service = service_fixture()
      assert %Ecto.Changeset{} = Store.change_service(service)
    end
  end
end

defmodule SalesReg.StoreTest do
  use SalesReg.DataCase

  alias SalesReg.Store

  describe "products" do
    alias SalesReg.Store.Product

    @valid_attrs %{
      description: "some description",
      image: "some image",
      name: "some name",
      pack_quantity: "some pack_quantity",
      price_per_pack: "some price_per_pack",
      price: "some price",
      unit_quantity: "some unit_quantity"
    }
    @update_attrs %{
      description: "some updated description",
      image: "some updated image",
      name: "some updated name",
      pack_quantity: "some updated pack_quantity",
      price_per_pack: "some updated price_per_pack",
      price: "some updated price",
      unit_quantity: "some updated unit_quantity"
    }
    @invalid_attrs %{
      description: nil,
      image: nil,
      name: nil,
      pack_quantity: nil,
      price_per_pack: nil,
      price: nil,
      unit_quantity: nil
    }

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
      assert product.price == "some price"
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
      assert product.price == "some updated price"
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

  describe "product_groups" do
    alias SalesReg.Store.ProductGroup

    @valid_attrs %{title: "some title"}
    @update_attrs %{title: "some updated title"}
    @invalid_attrs %{title: nil}

    def product_group_fixture(attrs \\ %{}) do
      {:ok, product_group} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Store.create_product_group()

      product_group
    end

    test "list_product_groups/0 returns all product_groups" do
      product_group = product_group_fixture()
      assert Store.list_product_groups() == [product_group]
    end

    test "get_product_group!/1 returns the product_group with given id" do
      product_group = product_group_fixture()
      assert Store.get_product_group!(product_group.id) == product_group
    end

    test "create_product_group/1 with valid data creates a product_group" do
      assert {:ok, %ProductGroup{} = product_group} = Store.create_product_group(@valid_attrs)
      assert product_group.title == "some title"
    end

    test "create_product_group/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Store.create_product_group(@invalid_attrs)
    end

    test "update_product_group/2 with valid data updates the product_group" do
      product_group = product_group_fixture()
      assert {:ok, product_group} = Store.update_product_group(product_group, @update_attrs)
      assert %ProductGroup{} = product_group
      assert product_group.title == "some updated title"
    end

    test "update_product_group/2 with invalid data returns error changeset" do
      product_group = product_group_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Store.update_product_group(product_group, @invalid_attrs)

      assert product_group == Store.get_product_group!(product_group.id)
    end

    test "delete_product_group/1 deletes the product_group" do
      product_group = product_group_fixture()
      assert {:ok, %ProductGroup{}} = Store.delete_product_group(product_group)
      assert_raise Ecto.NoResultsError, fn -> Store.get_product_group!(product_group.id) end
    end

    test "change_product_group/1 returns a product_group changeset" do
      product_group = product_group_fixture()
      assert %Ecto.Changeset{} = Store.change_product_group(product_group)
    end
  end

  describe "option_values" do
    alias SalesReg.Store.OptionValue

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def option_values_fixture(attrs \\ %{}) do
      {:ok, option_values} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Store.create_option_values()

      option_values
    end

    test "list_option_values/0 returns all option_values" do
      option_values = option_values_fixture()
      assert Store.list_option_values() == [option_values]
    end

    test "get_option_values!/1 returns the option_values with given id" do
      option_values = option_values_fixture()
      assert Store.get_option_values!(option_values.id) == option_values
    end

    test "create_option_values/1 with valid data creates a option_values" do
      assert {:ok, %OptionValue{} = option_values} = Store.create_option_values(@valid_attrs)
      assert option_values.name == "some name"
    end

    test "create_option_values/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Store.create_option_values(@invalid_attrs)
    end

    test "update_option_values/2 with valid data updates the option_values" do
      option_values = option_values_fixture()
      assert {:ok, option_values} = Store.update_option_values(option_values, @update_attrs)
      assert %OptionValue{} = option_values
      assert option_values.name == "some updated name"
    end

    test "update_option_values/2 with invalid data returns error changeset" do
      option_values = option_values_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Store.update_option_values(option_values, @invalid_attrs)

      assert option_values == Store.get_option_values!(option_values.id)
    end

    test "delete_option_values/1 deletes the option_values" do
      option_values = option_values_fixture()
      assert {:ok, %OptionValue{}} = Store.delete_option_values(option_values)
      assert_raise Ecto.NoResultsError, fn -> Store.get_option_values!(option_values.id) end
    end

    test "change_option_values/1 returns a option_values changeset" do
      option_values = option_values_fixture()
      assert %Ecto.Changeset{} = Store.change_option_values(option_values)
    end
  end
end

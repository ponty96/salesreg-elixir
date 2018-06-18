defmodule SalesReg.OrderTest do
  use SalesReg.DataCase

  alias SalesReg.Order

  describe "purchases" do
    alias SalesReg.Order.Purchase

    @valid_attrs %{
      data: "some data",
      payment_method: "some payment_method",
      purchasing_agent: "some purchasing_agent",
      status: "some status"
    }
    @update_attrs %{
      data: "some updated data",
      payment_method: "some updated payment_method",
      purchasing_agent: "some updated purchasing_agent",
      status: "some updated status"
    }
    @invalid_attrs %{data: nil, payment_method: nil, purchasing_agent: nil, status: nil}

    def purchase_fixture(attrs \\ %{}) do
      {:ok, purchase} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Order.create_purchase()

      purchase
    end

    test "list_purchases/0 returns all purchases" do
      purchase = purchase_fixture()
      assert Order.list_purchases() == [purchase]
    end

    test "get_purchase!/1 returns the purchase with given id" do
      purchase = purchase_fixture()
      assert Order.get_purchase!(purchase.id) == purchase
    end

    test "create_purchase/1 with valid data creates a purchase" do
      assert {:ok, %Purchase{} = purchase} = Order.create_purchase(@valid_attrs)
      assert purchase.data == "some data"
      assert purchase.payment_method == "some payment_method"
      assert purchase.purchasing_agent == "some purchasing_agent"
      assert purchase.status == "some status"
    end

    test "create_purchase/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Order.create_purchase(@invalid_attrs)
    end

    test "update_purchase/2 with valid data updates the purchase" do
      purchase = purchase_fixture()
      assert {:ok, purchase} = Order.update_purchase(purchase, @update_attrs)
      assert %Purchase{} = purchase
      assert purchase.data == "some updated data"
      assert purchase.payment_method == "some updated payment_method"
      assert purchase.purchasing_agent == "some updated purchasing_agent"
      assert purchase.status == "some updated status"
    end

    test "update_purchase/2 with invalid data returns error changeset" do
      purchase = purchase_fixture()
      assert {:error, %Ecto.Changeset{}} = Order.update_purchase(purchase, @invalid_attrs)
      assert purchase == Order.get_purchase!(purchase.id)
    end

    test "delete_purchase/1 deletes the purchase" do
      purchase = purchase_fixture()
      assert {:ok, %Purchase{}} = Order.delete_purchase(purchase)
      assert_raise Ecto.NoResultsError, fn -> Order.get_purchase!(purchase.id) end
    end

    test "change_purchase/1 returns a purchase changeset" do
      purchase = purchase_fixture()
      assert %Ecto.Changeset{} = Order.change_purchase(purchase)
    end
  end
end

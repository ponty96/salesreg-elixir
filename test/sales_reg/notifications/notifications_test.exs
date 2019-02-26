defmodule SalesReg.NotificationsTest do
  use SalesReg.DataCase

  alias SalesReg.Notifications

  describe "mobile_devices" do
    alias SalesReg.Notifications.MobileDevice

    @valid_attrs %{
      app_version: "some app_version",
      brand: "some brand",
      build_number: "some build_number",
      device_token: "some device_token",
      mobile_os: "some mobile_os",
      notification_enabled: "some notification_enabled"
    }
    @update_attrs %{
      app_version: "some updated app_version",
      brand: "some updated brand",
      build_number: "some updated build_number",
      device_token: "some updated device_token",
      mobile_os: "some updated mobile_os",
      notification_enabled: "some updated notification_enabled"
    }
    @invalid_attrs %{
      app_version: nil,
      brand: nil,
      build_number: nil,
      device_token: nil,
      mobile_os: nil,
      notification_enabled: nil
    }

    def mobile_device_fixture(attrs \\ %{}) do
      {:ok, mobile_device} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Notifications.create_mobile_device()

      mobile_device
    end

    test "list_mobile_devices/0 returns all mobile_devices" do
      mobile_device = mobile_device_fixture()
      assert Notifications.list_mobile_devices() == [mobile_device]
    end

    test "get_mobile_device!/1 returns the mobile_device with given id" do
      mobile_device = mobile_device_fixture()
      assert Notifications.get_mobile_device!(mobile_device.id) == mobile_device
    end

    test "create_mobile_device/1 with valid data creates a mobile_device" do
      assert {:ok, %MobileDevice{} = mobile_device} =
               Notifications.create_mobile_device(@valid_attrs)

      assert mobile_device.app_version == "some app_version"
      assert mobile_device.brand == "some brand"
      assert mobile_device.build_number == "some build_number"
      assert mobile_device.device_token == "some device_token"
      assert mobile_device.mobile_os == "some mobile_os"
      assert mobile_device.notification_enabled == "some notification_enabled"
    end

    test "create_mobile_device/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Notifications.create_mobile_device(@invalid_attrs)
    end

    test "update_mobile_device/2 with valid data updates the mobile_device" do
      mobile_device = mobile_device_fixture()

      assert {:ok, mobile_device} =
               Notifications.update_mobile_device(mobile_device, @update_attrs)

      assert %MobileDevice{} = mobile_device
      assert mobile_device.app_version == "some updated app_version"
      assert mobile_device.brand == "some updated brand"
      assert mobile_device.build_number == "some updated build_number"
      assert mobile_device.device_token == "some updated device_token"
      assert mobile_device.mobile_os == "some updated mobile_os"
      assert mobile_device.notification_enabled == "some updated notification_enabled"
    end

    test "update_mobile_device/2 with invalid data returns error changeset" do
      mobile_device = mobile_device_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Notifications.update_mobile_device(mobile_device, @invalid_attrs)

      assert mobile_device == Notifications.get_mobile_device!(mobile_device.id)
    end

    test "delete_mobile_device/1 deletes the mobile_device" do
      mobile_device = mobile_device_fixture()
      assert {:ok, %MobileDevice{}} = Notifications.delete_mobile_device(mobile_device)

      assert_raise Ecto.NoResultsError, fn ->
        Notifications.get_mobile_device!(mobile_device.id)
      end
    end

    test "change_mobile_device/1 returns a mobile_device changeset" do
      mobile_device = mobile_device_fixture()
      assert %Ecto.Changeset{} = Notifications.change_mobile_device(mobile_device)
    end
  end
end

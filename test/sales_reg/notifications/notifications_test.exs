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

  describe "notifications" do
    alias SalesReg.Notifications.Notification

    @valid_attrs %{
      action_type: "some action_type",
      delivery_channel: "some delivery_channel",
      delivery_status: "some delivery_status",
      element: "some element",
      read_status: "some read_status"
    }
    @update_attrs %{
      action_type: "some updated action_type",
      delivery_channel: "some updated delivery_channel",
      delivery_status: "some updated delivery_status",
      element: "some updated element",
      read_status: "some updated read_status"
    }
    @invalid_attrs %{
      action_type: nil,
      delivery_channel: nil,
      delivery_status: nil,
      element: nil,
      read_status: nil
    }

    def notification_fixture(attrs \\ %{}) do
      {:ok, notification} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Notifications.create_notification()

      notification
    end

    test "list_notifications/0 returns all notifications" do
      notification = notification_fixture()
      assert Notifications.list_notifications() == [notification]
    end

    test "get_notification!/1 returns the notification with given id" do
      notification = notification_fixture()
      assert Notifications.get_notification!(notification.id) == notification
    end

    test "create_notification/1 with valid data creates a notification" do
      assert {:ok, %Notification{} = notification} =
               Notifications.create_notification(@valid_attrs)

      assert notification.action_type == "some action_type"
      assert notification.delivery_channel == "some delivery_channel"
      assert notification.delivery_status == "some delivery_status"
      assert notification.element == "some element"
      assert notification.read_status == "some read_status"
    end

    test "create_notification/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Notifications.create_notification(@invalid_attrs)
    end

    test "update_notification/2 with valid data updates the notification" do
      notification = notification_fixture()
      assert {:ok, notification} = Notifications.update_notification(notification, @update_attrs)
      assert %Notification{} = notification
      assert notification.action_type == "some updated action_type"
      assert notification.delivery_channel == "some updated delivery_channel"
      assert notification.delivery_status == "some updated delivery_status"
      assert notification.element == "some updated element"
      assert notification.read_status == "some updated read_status"
    end

    test "update_notification/2 with invalid data returns error changeset" do
      notification = notification_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Notifications.update_notification(notification, @invalid_attrs)

      assert notification == Notifications.get_notification!(notification.id)
    end

    test "delete_notification/1 deletes the notification" do
      notification = notification_fixture()
      assert {:ok, %Notification{}} = Notifications.delete_notification(notification)
      assert_raise Ecto.NoResultsError, fn -> Notifications.get_notification!(notification.id) end
    end

    test "change_notification/1 returns a notification changeset" do
      notification = notification_fixture()
      assert %Ecto.Changeset{} = Notifications.change_notification(notification)
    end
  end

  describe "notification_items" do
    alias SalesReg.Notifications.NotificationItem

    @valid_attrs %{
      changed_to: "some changed_to",
      current: "some current",
      id: "some id",
      item_type: "some item_type"
    }
    @update_attrs %{
      changed_to: "some updated changed_to",
      current: "some updated current",
      id: "some updated id",
      item_type: "some updated item_type"
    }
    @invalid_attrs %{changed_to: nil, current: nil, id: nil, item_type: nil}

    def notification_item_fixture(attrs \\ %{}) do
      {:ok, notification_item} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Notifications.create_notification_item()

      notification_item
    end

    test "list_notification_items/0 returns all notification_items" do
      notification_item = notification_item_fixture()
      assert Notifications.list_notification_items() == [notification_item]
    end

    test "get_notification_item!/1 returns the notification_item with given id" do
      notification_item = notification_item_fixture()
      assert Notifications.get_notification_item!(notification_item.id) == notification_item
    end

    test "create_notification_item/1 with valid data creates a notification_item" do
      assert {:ok, %NotificationItem{} = notification_item} =
               Notifications.create_notification_item(@valid_attrs)

      assert notification_item.changed_to == "some changed_to"
      assert notification_item.current == "some current"
      assert notification_item.id == "some id"
      assert notification_item.item_type == "some item_type"
    end

    test "create_notification_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Notifications.create_notification_item(@invalid_attrs)
    end

    test "update_notification_item/2 with valid data updates the notification_item" do
      notification_item = notification_item_fixture()

      assert {:ok, notification_item} =
               Notifications.update_notification_item(notification_item, @update_attrs)

      assert %NotificationItem{} = notification_item
      assert notification_item.changed_to == "some updated changed_to"
      assert notification_item.current == "some updated current"
      assert notification_item.id == "some updated id"
      assert notification_item.item_type == "some updated item_type"
    end

    test "update_notification_item/2 with invalid data returns error changeset" do
      notification_item = notification_item_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Notifications.update_notification_item(notification_item, @invalid_attrs)

      assert notification_item == Notifications.get_notification_item!(notification_item.id)
    end

    test "delete_notification_item/1 deletes the notification_item" do
      notification_item = notification_item_fixture()

      assert {:ok, %NotificationItem{}} =
               Notifications.delete_notification_item(notification_item)

      assert_raise Ecto.NoResultsError, fn ->
        Notifications.get_notification_item!(notification_item.id)
      end
    end

    test "change_notification_item/1 returns a notification_item changeset" do
      notification_item = notification_item_fixture()
      assert %Ecto.Changeset{} = Notifications.change_notification_item(notification_item)
    end
  end
end

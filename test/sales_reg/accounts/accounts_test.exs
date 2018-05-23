defmodule SalesReg.AccountsTest do
  use SalesReg.DataCase

  alias SalesReg.Accounts

  describe "users" do
    alias SalesReg.Accounts.User

    @valid_attrs %{
      date_of_birth: "some date_of_birth",
      email: "some email",
      first_name: "some first_name",
      gender: "some gender",
      last_name: "some last_name",
      password: "some password",
      profile_pciture: "some profile_pciture"
    }
    @update_attrs %{
      date_of_birth: "some updated date_of_birth",
      email: "some updated email",
      first_name: "some updated first_name",
      gender: "some updated gender",
      last_name: "some updated last_name",
      password: "some updated password",
      profile_pciture: "some updated profile_pciture"
    }
    @invalid_attrs %{
      date_of_birth: nil,
      email: nil,
      first_name: nil,
      gender: nil,
      last_name: nil,
      password: nil,
      profile_pciture: nil
    }

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.date_of_birth == "some date_of_birth"
      assert user.email == "some email"
      assert user.first_name == "some first_name"
      assert user.gender == "some gender"
      assert user.last_name == "some last_name"
      assert user.password == "some password"
      assert user.profile_pciture == "some profile_pciture"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, user} = Accounts.update_user(user, @update_attrs)
      assert %User{} = user
      assert user.date_of_birth == "some updated date_of_birth"
      assert user.email == "some updated email"
      assert user.first_name == "some updated first_name"
      assert user.gender == "some updated gender"
      assert user.last_name == "some updated last_name"
      assert user.password == "some updated password"
      assert user.profile_pciture == "some updated profile_pciture"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end
end

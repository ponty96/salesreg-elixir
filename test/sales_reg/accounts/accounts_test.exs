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
      profile_pciture: "some profile_picture"
    }
    @update_attrs %{
      date_of_birth: "some updated date_of_birth",
      email: "some updated email",
      first_name: "some updated first_name",
      gender: "some updated gender",
      last_name: "some updated last_name",
      password: "some updated password",
      profile_pciture: "some updated profile_picture"
    }
    @invalid_attrs %{
      date_of_birth: nil,
      email: nil,
      first_name: nil,
      gender: nil,
      last_name: nil,
      password: nil,
      profile_picture: nil
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

    test "get_user/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.date_of_birth == "some date_of_birth"
      assert user.email == "some email"
      assert user.first_name == "some first_name"
      assert user.gender == "some gender"
      assert user.last_name == "some last_name"
      assert user.password == "some password"
      assert user.profile_picture == "some profile_picture"
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
      assert user.profile_picture == "some updated profile_picture"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "login_attempts" do
    alias SalesReg.Accounts.LoginAttempt

    @valid_attrs %{mac_address: "some mac_address", white_listed: "some white_listed"}
    @update_attrs %{
      mac_address: "some updated mac_address",
      white_listed: "some updated white_listed"
    }
    @invalid_attrs %{mac_address: nil, white_listed: nil}

    def login_attempt_fixture(attrs \\ %{}) do
      {:ok, login_attempt} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_login_attempt()

      login_attempt
    end

    test "list_login_attempts/0 returns all login_attempts" do
      login_attempt = login_attempt_fixture()
      assert Accounts.list_login_attempts() == [login_attempt]
    end

    test "get_login_attempt!/1 returns the login_attempt with given id" do
      login_attempt = login_attempt_fixture()
      assert Accounts.get_login_attempt!(login_attempt.id) == login_attempt
    end

    test "create_login_attempt/1 with valid data creates a login_attempt" do
      assert {:ok, %LoginAttempt{} = login_attempt} = Accounts.create_login_attempt(@valid_attrs)
      assert login_attempt.mac_address == "some mac_address"
      assert login_attempt.white_listed == "some white_listed"
    end

    test "create_login_attempt/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_login_attempt(@invalid_attrs)
    end

    test "update_login_attempt/2 with valid data updates the login_attempt" do
      login_attempt = login_attempt_fixture()
      assert {:ok, login_attempt} = Accounts.update_login_attempt(login_attempt, @update_attrs)
      assert %LoginAttempt{} = login_attempt
      assert login_attempt.mac_address == "some updated mac_address"
      assert login_attempt.white_listed == "some updated white_listed"
    end

    test "update_login_attempt/2 with invalid data returns error changeset" do
      login_attempt = login_attempt_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Accounts.update_login_attempt(login_attempt, @invalid_attrs)

      assert login_attempt == Accounts.get_login_attempt!(login_attempt.id)
    end

    test "delete_login_attempt/1 deletes the login_attempt" do
      login_attempt = login_attempt_fixture()
      assert {:ok, %LoginAttempt{}} = Accounts.delete_login_attempt(login_attempt)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_login_attempt!(login_attempt.id) end
    end

    test "change_login_attempt/1 returns a login_attempt changeset" do
      login_attempt = login_attempt_fixture()
      assert %Ecto.Changeset{} = Accounts.change_login_attempt(login_attempt)
    end
  end
end

defmodule SalesReg.BusinessTest do
  use SalesReg.DataCase

  alias SalesReg.Business

  describe "companies" do
    alias SalesReg.Business.Company

    @valid_attrs %{about: "some about", contact_email: "some contact_email", title: "some title"}
    @update_attrs %{
      about: "some updated about",
      contact_email: "some updated contact_email",
      title: "some updated title"
    }
    @invalid_attrs %{about: nil, contact_email: nil, title: nil}

    def company_fixture(attrs \\ %{}) do
      {:ok, company} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Business.create_company()

      company
    end

    test "list_companies/0 returns all companies" do
      company = company_fixture()
      assert Business.list_companies() == [company]
    end

    test "get_company!/1 returns the company with given id" do
      company = company_fixture()
      assert Business.get_company!(company.id) == company
    end

    test "create_company/1 with valid data creates a company" do
      assert {:ok, %Company{} = company} = Business.create_company(@valid_attrs)
      assert company.about == "some about"
      assert company.contact_email == "some contact_email"
      assert company.title == "some title"
    end

    test "create_company/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Business.create_company(@invalid_attrs)
    end

    test "update_company/2 with valid data updates the company" do
      company = company_fixture()
      assert {:ok, company} = Business.update_company(company, @update_attrs)
      assert %Company{} = company
      assert company.about == "some updated about"
      assert company.contact_email == "some updated contact_email"
      assert company.title == "some updated title"
    end

    test "update_company/2 with invalid data returns error changeset" do
      company = company_fixture()
      assert {:error, %Ecto.Changeset{}} = Business.update_company(company, @invalid_attrs)
      assert company == Business.get_company!(company.id)
    end

    test "delete_company/1 deletes the company" do
      company = company_fixture()
      assert {:ok, %Company{}} = Business.delete_company(company)
      assert_raise Ecto.NoResultsError, fn -> Business.get_company!(company.id) end
    end

    test "change_company/1 returns a company changeset" do
      company = company_fixture()
      assert %Ecto.Changeset{} = Business.change_company(company)
    end
  end

  describe "branches" do
    alias SalesReg.Business.Branch

    @valid_attrs %{type: "some type"}
    @update_attrs %{type: "some updated type"}
    @invalid_attrs %{type: nil}

    def branch_fixture(attrs \\ %{}) do
      {:ok, branch} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Business.create_branch()

      branch
    end

    test "list_branches/0 returns all branches" do
      branch = branch_fixture()
      assert Business.list_branches() == [branch]
    end

    test "get_branch!/1 returns the branch with given id" do
      branch = branch_fixture()
      assert Business.get_branch!(branch.id) == branch
    end

    test "create_branch/1 with valid data creates a branch" do
      assert {:ok, %Branch{} = branch} = Business.create_branch(@valid_attrs)
      assert branch.type == "some type"
    end

    test "create_branch/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Business.create_branch(@invalid_attrs)
    end

    test "update_branch/2 with valid data updates the branch" do
      branch = branch_fixture()
      assert {:ok, branch} = Business.update_branch(branch, @update_attrs)
      assert %Branch{} = branch
      assert branch.type == "some updated type"
    end

    test "update_branch/2 with invalid data returns error changeset" do
      branch = branch_fixture()
      assert {:error, %Ecto.Changeset{}} = Business.update_branch(branch, @invalid_attrs)
      assert branch == Business.get_branch!(branch.id)
    end

    test "delete_branch/1 deletes the branch" do
      branch = branch_fixture()
      assert {:ok, %Branch{}} = Business.delete_branch(branch)
      assert_raise Ecto.NoResultsError, fn -> Business.get_branch!(branch.id) end
    end

    test "change_branch/1 returns a branch changeset" do
      branch = branch_fixture()
      assert %Ecto.Changeset{} = Business.change_branch(branch)
    end
  end

  describe "employees" do
    alias SalesReg.Business.Employee

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def employee_fixture(attrs \\ %{}) do
      {:ok, employee} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Business.create_employee()

      employee
    end

    test "list_employees/0 returns all employees" do
      employee = employee_fixture()
      assert Business.list_employees() == [employee]
    end

    test "get_employee!/1 returns the employee with given id" do
      employee = employee_fixture()
      assert Business.get_employee!(employee.id) == employee
    end

    # test "create_employee/1 with valid data creates a employee" do
    #   assert {:ok, %Employee{} = employee} = Business.create_employee(@valid_attrs)
    # end

    test "create_employee/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Business.create_employee(@invalid_attrs)
    end

    test "update_employee/2 with valid data updates the employee" do
      employee = employee_fixture()
      assert {:ok, employee} = Business.update_employee(employee, @update_attrs)
      assert %Employee{} = employee
    end

    test "update_employee/2 with invalid data returns error changeset" do
      employee = employee_fixture()
      assert {:error, %Ecto.Changeset{}} = Business.update_employee(employee, @invalid_attrs)
      assert employee == Business.get_employee!(employee.id)
    end

    test "delete_employee/1 deletes the employee" do
      employee = employee_fixture()
      assert {:ok, %Employee{}} = Business.delete_employee(employee)
      assert_raise Ecto.NoResultsError, fn -> Business.get_employee!(employee.id) end
    end

    test "change_employee/1 returns a employee changeset" do
      employee = employee_fixture()
      assert %Ecto.Changeset{} = Business.change_employee(employee)
    end
  end

  describe "locations" do
    alias SalesReg.Business.Location

    @valid_attrs %{
      city: "some city",
      country: "some country",
      lat: "some lat",
      long: "some long",
      state: "some state",
      street1: "some street1",
      street2: "some street2"
    }
    @update_attrs %{
      city: "some updated city",
      country: "some updated country",
      lat: "some updated lat",
      long: "some updated long",
      state: "some updated state",
      street1: "some updated street1",
      street2: "some updated street2"
    }
    @invalid_attrs %{
      city: nil,
      country: nil,
      lat: nil,
      long: nil,
      state: nil,
      street1: nil,
      street2: nil
    }

    def location_fixture(attrs \\ %{}) do
      {:ok, location} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Business.create_location()

      location
    end

    test "list_locations/0 returns all locations" do
      location = location_fixture()
      assert Business.list_locations() == [location]
    end

    test "get_location!/1 returns the location with given id" do
      location = location_fixture()
      assert Business.get_location!(location.id) == location
    end

    test "create_location/1 with valid data creates a location" do
      assert {:ok, %Location{} = location} = Business.create_location(@valid_attrs)
      assert location.city == "some city"
      assert location.country == "some country"
      assert location.lat == "some lat"
      assert location.long == "some long"
      assert location.state == "some state"
      assert location.street1 == "some street1"
      assert location.street2 == "some street2"
    end

    test "create_location/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Business.create_location(@invalid_attrs)
    end

    test "update_location/2 with valid data updates the location" do
      location = location_fixture()
      assert {:ok, location} = Business.update_location(location, @update_attrs)
      assert %Location{} = location
      assert location.city == "some updated city"
      assert location.country == "some updated country"
      assert location.lat == "some updated lat"
      assert location.long == "some updated long"
      assert location.state == "some updated state"
      assert location.street1 == "some updated street1"
      assert location.street2 == "some updated street2"
    end

    test "update_location/2 with invalid data returns error changeset" do
      location = location_fixture()
      assert {:error, %Ecto.Changeset{}} = Business.update_location(location, @invalid_attrs)
      assert location == Business.get_location!(location.id)
    end

    test "delete_location/1 deletes the location" do
      location = location_fixture()
      assert {:ok, %Location{}} = Business.delete_location(location)
      assert_raise Ecto.NoResultsError, fn -> Business.get_location!(location.id) end
    end

    test "change_location/1 returns a location changeset" do
      location = location_fixture()
      assert %Ecto.Changeset{} = Business.change_location(location)
    end
  end
end

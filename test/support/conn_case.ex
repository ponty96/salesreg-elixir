defmodule SalesRegWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common datastructures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest
      import SalesRegWeb.Router.Helpers

      alias SalesReg.{
        Business,
        Accounts,
        Seed
      }

      alias SalesRegWeb.GraphqlTestHelpers, as: Helpers
      alias SalesReg.Seed

      # The default endpoint for testing
      @endpoint SalesRegWeb.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(SalesReg.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(SalesReg.Repo, {:shared, self()})
    end

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  @user_params %{
    date_of_birth: "20-11-1999",
    email: "someemail@gmail.com",
    first_name: "firstname",
    gender: "Male",
    last_name: "lastname",
    password: "asdfasdf",
    password_confirmation: "asdfasdf",
    profile_picture: "picture.jpg"
  }

  @company_params %{
    title: "this is the title",
    contact_email: "someemail@gmail.com",
    currency: "Euro",
    phone: %{
      number: "+2348131900893"
    }
  }

  # this is called for all tests
  setup %{conn: conn} do
    {:ok, user} = SalesReg.Accounts.create_user(@user_params)
    login_params = %{email: user.email, password: user.password}
    conn = SalesRegWeb.GraphqlTestHelpers.authenticate(conn, login_params)

    {:ok, company} =
      user.id
      |> SalesReg.Business.create_company(@company_params)

    %{user: user, conn: conn, company: company}
  end
end

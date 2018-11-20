ExUnit.configure(exclude: [skip: true])
ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(SalesReg.Repo, :manual)

defmodule SalesReg.Application do
  @moduledoc """
    Application Module
  """
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      {Task.Supervisor, name: SalesReg.TaskSupervisor},
      # Start the Ecto repository
      supervisor(SalesReg.Repo, []),
      # Start the endpoint when the application starts
      supervisor(SalesRegWeb.Endpoint, []),
      # Start your own worker by calling: SalesReg.Worker.start_link(arg1, arg2, arg3)
      # worker(SalesReg.Worker, [arg1, arg2, arg3]),
      worker(Guardian.DB.Token.SweeperServer, []),
      worker(SalesReg.Scheduler, [])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SalesReg.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    SalesRegWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

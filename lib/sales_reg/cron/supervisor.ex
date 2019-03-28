defmodule SalesReg.Scheduler do
  @moduledoc """
  Cron Scheduler
  """
  use Quantum.Scheduler,
    otp_app: :sales_reg
end

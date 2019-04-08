defmodule SalesReg.Mailer do
  @moduledoc """
    Mailer Module
  """
  use Bamboo.Mailer, otp_app: :sales_reg

  def naive_date(date) when is_binary(date) do
    {:ok, date} = Timex.parse(date, "{YYYY}-{0M}-{D}")
    date
  end
end

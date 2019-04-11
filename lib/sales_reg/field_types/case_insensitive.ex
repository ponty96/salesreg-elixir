defmodule SalesReg.FieldTypes.CaseInsensitive do
  @moduledoc """
    Case Insensitive Ecto Field Type
  """
  @behaviour Ecto.Type
  def type, do: :string

  def load(data) do
    {:ok, String.downcase(data)}
  end

  def cast(data) do
    {:ok, data}
  end

  def dump(data) do
    {:ok, data}
  end
end

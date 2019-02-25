defmodule SalesRegWeb.Services.Base do
  def request(method, url, body, headers \\ [], opts \\ []) do
    HTTPoison.request(method, url, body, headers ++ default_header, opts)
  end

  def encode(data) do
    Poison.encode!(data)
  end

  def process_response({:ok, %HTTPoison.Response{status_code: status} = response})
      when status in [200, 201, 202, 206] do
    {:ok, :success, Poison.decode!(response.body)}
  end

  def process_response({:ok, %HTTPoison.Response{status_code: _status} = response}) do
    {:ok, :fail, Poison.decode!(response.body)}
  end

  def process_response({:error, response}) do
    IO.inspect(response, label: "Request Response")
    {:error, response.reason}
  end

  ## timeout => used to establish a connection, in milliseconds. Default is 8000(check HTTPoison docs)
  ## recv_timeout => used when receiving a connection. Default is 5000(check HTTPoison docs) 
  def set_default_timeout(opts) do
    [timeout: 10_000, recv_timeout: 10_000] ++ opts
  end

  def default_header() do
    [{"Content-Type", "application/json"}]
  end
end

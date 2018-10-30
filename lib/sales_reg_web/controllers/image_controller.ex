defmodule SalesRegWeb.ImageController do
  use SalesRegWeb, :controller
  alias SalesReg.ImageUpload

  def upload_image(conn, %{"image_binary" => image_binary}) do
    filename = ImageUpload.upload_image(image_binary)
    case is_binary(filename) do
      true ->
        conn
        |> put_status(209)
        |> json(%{file_url: %{
            original: ImageUpload.url({filename, %{}}),
            thumb: ImageUpload.url({filename, %{}}, :thumb)
          }
        })

      false ->
        conn
        |> put_status(210)
        |> json(nil)
    end
  end
end

defmodule SalesRegWeb.ImageController do
  use SalesRegWeb, :controller

  def upload_image(conn, %{"image_binary" => _image_binary}) do
    conn
  end
end

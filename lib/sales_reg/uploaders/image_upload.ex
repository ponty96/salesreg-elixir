defmodule SalesReg.ImageUpload do
  use Arc.Definition

  # Include ecto support (requires package arc_ecto installed):
  # use Arc.Ecto.Definition

  @versions [:original, :thumb]
  @acl :public_read

  # Override the bucket on a per definition basis:
  def bucket do
    :yipcartimages
  end

  # Whitelist file extensions:
  def validate({file, _}) do
    ~w(.jpg .jpeg .gif .png) |> Enum.member?(Path.extname(file.file_name))
  end

  # Define a thumbnail transformation:
  def transform(:thumb, _) do
    {:convert, "-strip -thumbnail 250x250^ -gravity center -extent 250x250 -format png", :png}
  end

  # Override the persisted filenames:
  def filename(version, _) do
    version
  end

  # Override the storage directory:
  # def storage_dir(version, {file, scope}) do
  #   "uploads/user/avatars/#{scope.id}"
  # end

  # Provide a default URL if there hasn't been a file uploaded
  def default_url(version, scope) do
    "/images/avatars/default_#{version}.png"
  end

  # Specify custom headers for s3 objects
  # Available options are [:cache_control, :content_disposition,
  #    :content_encoding, :content_length, :content_type,
  #    :expect, :expires, :storage_class, :website_redirect_location]
  #
  def s3_object_headers(version, {file, scope}) do
    [content_type: MIME.from_path(file.file_name)]
  end

  def upload_image(binary) do
    decode_binary = Base.decode64(binary)
    case decode_binary do
      {:ok, image_binary} -> 
        __MODULE__.store(image_binary)
        |> handle_response()
      
      _  -> 
        :error
    end
  end

  defp handle_response({:ok, filename}) do
    {:ok, filename}
  end

  defp handle_response({:error, reason} = tuple) do
    :error
  end
end

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
    ~w(.pdf .jpg .jpeg .gif .png .pdf)
    |> Enum.member?(String.downcase(Path.extname(file.file_name)))
  end

  # Define a original transformation:
  def transform(:original, _), do: :noaction
  # Define a thumbnail transformation
  def transform(:thumb, _), do: :noaction

  # def transform(:thumb, {%{file_name: name}, _}) do
  #   case String.downcase(Path.extname(name)) do
  #     ".pdf" ->
  #       {:convert,
  #          fn input, output ->
  #            "-strip -thumbnail 100x100^ -verbose -density 150 -trim #{input}[0] -quality 100 -flatten -sharpen 0x1.0 png:#{
  #              output
  #            }"
  #          end, :png}

  #     ".png" ->
  #       {:convert, 
  #         "-strip -thumbnail 100x100^ -gravity center -extent 100x100"}

  #     ".jpg" ->
  #       {:convert, "-strip -thumbnail 120x120^ -gravity center -extent 120x120"}

  #     ".jpeg" ->
  #       {:convert, "-strip -thumbnail 120x120^ -gravity center -extent 120x120"}

  #     _ ->
  #       {:convert, "-strip -thumbnail 100x100^ -gravity center -extent 100x100 -format png", :png}
  #   end
  # end

  def filename(_version, {file, _scope}) do
    file_name = Path.basename(file.file_name, Path.extname(file.file_name))
    "#{file_name}"
  end

  # Override the persisted filenames:
  def filename(version, _) do
    version
  end

  # Override the storage directory:
  def storage_dir(_version, {_file, _scope}) do
    "uploads/pdfs/"
  end

  # Provide a default URL if there hasn't been a file uploaded
  def default_url(version, _scope) do
    "/images/avatars/default_#{version}.png"
  end

  # Specify custom headers for s3 objects
  # Available options are [:cache_control, :content_disposition,
  #    :content_encoding, :content_length, :content_type,
  #    :expect, :expires, :storage_class, :website_redirect_location]
  #
  def s3_object_headers(_version, {file, _scope}) do
    [content_type: MIME.from_path(file.file_name)]
  end
end

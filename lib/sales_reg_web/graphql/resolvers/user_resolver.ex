defmodule SalesRegWeb.GraphQL.Resolvers.UserResolver do
  alias SalesReg.Accounts
  alias SalesReg.Accounts.User
  alias SalesRegWeb.Authentication

  def get_user(%{id: id}, resolution) do
    case resolution do
      %{context: %{current_user: _}} ->
        user = Accounts.get_user(id)

        case user do
          %User{} ->
            {:ok, user}

          _ ->
            {:error, "Something went wrong. Try again!"}
        end

      _ ->
        {:ok, resolution}
    end
  end

  def login_user(params, _resolution) do
    Authentication.login(params)
  end

  def verify_tokens(params, _resolution) do
    Authentication.verify_tokens(params)
  end

  def refresh_token(params, _resolution) do
    Authentication.refresh_token(params)
  end

  def logout(params, _resolution) do
    Authentication.logout(params)
  end

  def update_user(%{id: user_id, user: user_params}, _res) do
    user = Accounts.get_user(user_id)

    case user do
      %User{} ->
        case user_params do
          %{profile_picture: nil} ->
            Accounts.update_user(user, user_params)

          %{profile_picture: image_base64} ->
            image_url = upload_image(image_base64)

            new_user_params = %{
              user_params
              | profile_picture: image_url
            }

            Accounts.update_user(user, new_user_params)
        end

      _ ->
        {:error, "User does not exist"}
    end
  end

  def upload_image(image_base64) do
    image_bucket = System.get_env("BUCKET_NAME")

    # Decode the image
    {:ok, image_binary} = Base.decode64(image_base64)

    # Generate a unique filename
    filename =
      image_binary
      |> image_extension()
      |> unique_filename()

    # Upload to S3
    {:ok, _response} =
      ExAws.S3.put_object(image_bucket, filename, image_binary)
      |> ExAws.request()

    # Generate the full URL to the newly uploaded image
    "https://#{image_bucket}.s3.amazonaws.com/#{filename}"
  end

  # Generates a unique filename with a given extension
  defp unique_filename(extension) do
    UUID.uuid4(:hex) <> extension
  end

  # Helper functions to read the binary to determine the image extension
  defp image_extension(<<0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, _::binary>>), do: ".png"
  defp image_extension(<<0xFF, 0xD8, _::binary>>), do: ".jpg"
end

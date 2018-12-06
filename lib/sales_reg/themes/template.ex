defmodule SalesReg.Themes.Template do
	use Ecto.Schema
	import Ecto.Changeset

	@primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

	schema "templates" do
    field(:title, :string)
		field(:slug, :string)
		field(:featured_image, :string)

		timestamps()

		@required_fields [
			:title,
			:slug,
			:featured_image
		]

		def changeset(template, attrs) do
			template
			|> cast(attrs, @required_fields)
			|> validate_required(@required_fields)
		end

	end
end
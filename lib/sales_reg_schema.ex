defmodule SalesRegWeb.Schemas do
  @moduledoc false
  use Absinthe.Schema

  import_types(SalesRegWeb.Types)
  import_types(SalesRegWeb.Schemas.User)

  query do
    import_fields(:single_user)
  end

  mutation do
    import_fields(:register_user)
    import_fields(:login_user)
  end
end

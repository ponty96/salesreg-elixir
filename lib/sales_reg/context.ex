defmodule SalesReg.Context do
  @moduledoc false

  defmacro __using__(modules) do
    quote bind_quoted: [modules: modules] do
      alias SalesReg.Repo
      alias Ecto.Query

      for module <- modules do
        schema =
          module
          |> Module.split()
          |> List.last()
          |> Macro.underscore()

        def unquote(String.to_atom("get_#{schema}"))(id, opts \\ []) do
          res =
            if preload = opts[:preload] do
              unquote(module)
              |> Query.where(id: ^id)
              |> Query.preload(^preload)
              |> Repo.one()
            else
              Repo.get(unquote(module), id)
            end

          case res do
            nil -> {:error, String.to_atom("#{unquote(schema)}_not_found")}
            resource -> {:ok, resource}
          end
        end

        def unquote(String.to_atom("list_company_#{schema}s"))(company_id) do
          res =
            unquote(module)
            |> Query.where(company_id: ^company_id)
            |> Repo.all()

          {:ok, res}
        end

        def unquote(String.to_atom("add_#{schema}"))(%{} = params) do
          # if mod == unquote(module) do
          #   unquote(module).__struct__
          #   |> mod.changeset(params)
          #   |> Repo.insert()
          # else
          #   raise "expected #{unquote(module)}"
          # end

          mod = unquote(module)

          mod.__struct__
          |> mod.changeset(params)
          |> Repo.insert()
        end

        def unquote(String.to_atom("update_#{schema}"))(%mod{} = resource, %{} = params) do
          if mod == unquote(module) do
            resource
            |> mod.changeset(params)
            |> Repo.update()
          else
            raise "expected #{unquote(module)}"
          end
        end

        def unquote(String.to_atom("delete_#{schema}"))(%mod{} = resource) do
          if mod == unquote(module) do
            resource
            |> mod.delete_changeset
            |> Repo.delete()
          else
            raise "expected #{unquote(module)}"
          end
        end

        Module.make_overridable(__MODULE__, [
          {String.to_atom("get_#{schema}"), 2},
          {String.to_atom("update_#{schema}"), 2},
          {String.to_atom("list_company_#{schema}s"), 1},
          {String.to_atom("add_#{schema}"), 1},
          {String.to_atom("delete_#{schema}"), 1}
        ])
      end
    end
  end
end

defmodule SalesReg.Context do
  @moduledoc false
  alias SalesReg.Repo

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

          res
        end

        def unquote(String.to_atom("list_company_#{schema}s"))(company_id) do
          res =
            unquote(module)
            |> Query.where(company_id: ^company_id)
            |> Query.order_by(desc: :updated_at)
            |> Repo.all()

          {:ok, res}
        end

        def unquote(String.to_atom("paginated_list_company_#{schema}s"))(clauses, args) do
          unquote(module)
          |> Query.where(^clauses)
          |> Query.order_by(desc: :updated_at)
          |> Absinthe.Relay.Connection.from_query(&Repo.all/1, args)
        end

        def unquote(String.to_atom("search_company_#{schema}s"))(clauses, query, field, args) do
          query_regex = "%" <> query <> "%"

          unquote(module)
          |> where(^clauses)
          |> where([s], ilike(field(s, ^field), ^query_regex))
          |> order_by(
            [s],
            fragment(
              "ts_rank(to_tsvector(?), plainto_tsquery(?)) DESC",
              field(s, ^field),
              ^query
            )
          )
          |> order_by(desc: :updated_at)
          |> Absinthe.Relay.Connection.from_query(&Repo.all/1, args)
        end

        def unquote(String.to_atom("add_#{schema}"))(%{} = params) do
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
            |> mod.delete_changeset()
            |> Repo.delete()
          else
            raise "expected #{unquote(module)}"
          end
        end

        def unquote(String.to_atom("all_#{schema}"))() do
          module = unquote(module)

          if module do
            module
            |> Repo.all()
          else
            raise "expected #{unquote(module)}"
          end
        end

        Module.make_overridable(__MODULE__, [
          {String.to_atom("get_#{schema}"), 2},
          {String.to_atom("update_#{schema}"), 2},
          {String.to_atom("list_company_#{schema}s"), 1},
          {String.to_atom("add_#{schema}"), 1},
          {String.to_atom("delete_#{schema}"), 1},
          {String.to_atom("all_#{schema}"), 0}
        ])
      end
    end
  end

  defmacro search_schema_by_field(schema, {query, company_id}, field) do
    quote do
      query_regex = "%" <> unquote(query) <> "%"

      unquote(schema)
      |> where(company_id: ^unquote(company_id))
      |> where([s], ilike(field(s, ^unquote(field)), ^query_regex))
      |> order_by(
        [s],
        fragment(
          "ts_rank(to_tsvector(?), plainto_tsquery(?)) DESC",
          field(s, ^unquote(field)),
          ^unquote(query)
        )
      )
      |> Repo.all()
    end
  end
end

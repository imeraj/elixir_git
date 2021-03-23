defmodule Egit.Commit do
  @moduledoc """
  An Elixir implementation of Git version control system
  """

  alias Egit.{Workspace, Database, Helpers}
  alias Egit.Types.{BLOB, Tree, Entry, Author, Commit, Refs, Layout}

  def commit(root_path, config) do
    head_path = root_path |> Helpers.head_path()
    parent = Refs.read_head(head_path)

    entries =
      Enum.map(
        Workspace.list_files(),
        fn path ->
          case File.read(path) do
            {:ok, data} ->
              blob = build_blob(data)
              Database.store(blob)
              %Entry{name: path, oid: blob.oid, stat: Workspace.stat_file(path)}

            {:error, _} ->
              nil
          end
        end
      )
      |> Enum.reject(&is_nil/1)

    root =
      Layout.build(entries)
      |> traverse()

    Database.store(root)

    author = %Author{name: config.name, email: config.email, time: DateTime.utc_now()}
    commit = build_commit(author, root, parent)
    Database.store(commit)

    Refs.update_head(head_path, commit.oid)

    message =
      case parent do
        nil -> "(root-commit) "
        _ -> ""
      end

    IO.puts("[#{message}#{commit.oid}] #{commit.message}")
  end

  defp traverse(root = %Tree{}) do
    new_entries =
      Map.new(root.entries, fn {name, entry} ->
        new_root = Tree.build_content(traverse(entry))
        Database.store(new_root)
        {name, new_root}
      end)

    Map.replace!(root, :entries, new_entries)
    |> Tree.build_content()
  end

  defp traverse(root), do: root

  defp build_blob(data) do
    object = %BLOB{data: data}
    string = BLOB.to_s(object)
    content = "#{BLOB.type(object)} #{byte_size(string)}\0#{string}"
    object = %{object | oid: String.downcase(:crypto.hash(:sha, content) |> Base.encode16())}
    %{object | content: content}
  end

  defp build_commit(author, tree, parent) do
    message = IO.gets("Enter commit message: \n")

    object = %Commit{
      tree: tree,
      message: String.trim(message, "\n"),
      author: author
    }

    string = Commit.to_s(object, parent)
    content = "#{Commit.type(object)} #{byte_size(string)}\0" <> string
    object = %{object | oid: String.downcase(:crypto.hash(:sha, content) |> Base.encode16())}
    %{object | content: content}
  end
end

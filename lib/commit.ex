defmodule Egit.Commit do
  @moduledoc """
  An Elixir implementation of Git version control system
  """

  alias Egit.{Workspace, Database, Helpers}
  alias Egit.Types.{BLOB, Tree, Entry, Author, Commit, Refs}

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
              %Entry{name: path, oid: blob.oid}

            {:error, _} ->
              nil
          end
        end
      )
      |> Enum.reject(&is_nil/1)

    tree = build_tree(entries)
    Database.store(tree)

    author = %Author{name: config.name, email: config.email, time: DateTime.utc_now()}
    commit = build_commit(author, tree, parent)
    Database.store(commit)

    Refs.update_head(head_path, commit.oid)

    message =
      case parent do
        nil -> "(root-commit) "
        _ -> ""
      end

    IO.puts("[#{message}#{commit.oid}] #{commit.message}")
  end

  def build_blob(data) do
    object = %BLOB{data: data}
    string = BLOB.to_s(object)
    content = "#{BLOB.type(object)} #{byte_size(string)}\0#{string}"
    object = %{object | oid: String.downcase(:crypto.hash(:sha, content) |> Base.encode16())}
    %{object | content: content}
  end

  def build_tree(entries) do
    object = %Tree{entries: entries}
    string = Tree.to_s(object)
    content = "#{Tree.type(object)} #{byte_size(string)}\0#{string}"
    object = %{object | oid: String.downcase(:crypto.hash(:sha, content) |> Base.encode16())}
    %{object | content: content}
  end

  def build_commit(author, tree, parent) do
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

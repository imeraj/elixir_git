defmodule Egit.Commit do
  @moduledoc """
  An Elixir implementation of Git version control system
  """

  alias Egit.{Workspace, Database, Helpers}
  alias Egit.Types.{BLOB, Tree, Entry, Author, Commit}

  def commit(root_path, config) do
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
    commit = build_commit(author, tree)
    Database.store(commit)

    root_path
    |> write_edit_msg(commit)
  end

  def write_edit_msg(root_path, commit) do
    {:ok, file} =
      Path.join(Helpers.git_path(root_path), "HEAD")
      |> File.open([:write])

    IO.binwrite(file, commit.oid)

    IO.puts("[(root-commit) #{commit.oid}] #{commit.message}")
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

  def build_commit(author, tree) do
    message = IO.gets("Enter commit message: \n")

    object = %Commit{
      tree: tree,
      message: String.trim(message, "\n"),
      author: author
    }

    string = Commit.to_s(object)
    content = "#{Commit.type(object)} #{byte_size(string)}\0" <> string
    object = %{object | oid: String.downcase(:crypto.hash(:sha, content) |> Base.encode16())}
    %{object | content: content}
  end
end

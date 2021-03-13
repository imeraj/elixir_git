defmodule Egit.Helpers do
  @moduledoc """
  An Elixir implementation of Git version control system
  """

  def git_path(root_path) do
    root_path
    |> Path.join(".git")
  end

  def head_path(root_path) do
    root_path
    |> git_path()
    |> Path.join("HEAD")
  end

  def db_path(root_path) do
    root_path
    |> git_path()
    |> Path.join("objects")
  end

  def ls_r(path \\ ".") do
    cond do
      File.regular?(path) ->
        [path]

      File.dir?(path) ->
        File.ls!(path)
        |> Enum.map(&Path.join(path, &1))
        |> Enum.map(&ls_r/1)
        |> Enum.concat()

      true ->
        []
    end
  end

  @bytes Enum.concat([?a..?z, ?A..?Z, ?0..?9]) |> List.to_string()
  def generate_random_string(length) do
    for _ <- 1..length, into: <<>> do
      index = :rand.uniform(byte_size(@bytes)) - 1
      <<:binary.at(@bytes, index)>>
    end
  end
end

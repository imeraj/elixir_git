defmodule Egit.Workspace do
  @moduledoc """
  An Elixir implementation of Git version control system
  """

  alias Egit.Helpers

  @ignore_path [".git"]

  def list_files(path \\ ".") do
    cond do
      File.regular?(path) ->
        [path]

      true ->
        list = Path.wildcard(Path.join(path, "/*"), match_dot: true) -- @ignore_path

        Enum.map(list, fn path -> Helpers.ls_r(path) end)
        |> List.flatten()
    end
  end

  def stat_file(path) do
    case File.stat(path) do
      {:ok, stat} ->
        stat

      {:error, reason} ->
        IO.puts(:stderr, "stat failed - #{reason}")
    end
  end

  def read_file(path) do
    case File.exists?(path) do
      true ->
        {:ok, data} = File.read(path)
        data

      false ->
        nil
    end
  end
end

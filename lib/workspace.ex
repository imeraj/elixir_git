defmodule Egit.Workspace do
  @moduledoc """
  An Elixir implementation of Git version control system
  """

  alias Egit.Helpers

  @ignore_path [".git"]

  def list_files do
    list = Path.wildcard("./*", match_dot: true) -- @ignore_path

    Enum.map(list, fn path -> Helpers.ls_r(path) end)
    |> List.flatten()
  end

  def stat_file(path) do
    case File.stat(path) do
      {:ok, stat} ->
        stat

      {:error, reason} ->
        IO.puts(:stderr, "stat failed - #{reason}")
    end
  end
end

defmodule Egit.Types.Commit do
  @moduledoc """
  An Elixir implementation of Git version control system
  """

  alias Egit.Types.Author

  defstruct tree: nil, author: nil, message: nil, oid: nil, content: nil

  def type(_commit) do
    "commit"
  end

  def to_s(commit, parent \\ nil) do
    lines = Enum.concat([], ["tree #{commit.tree.oid}"])

    lines =
      case parent do
        nil -> lines
        _ -> Enum.concat(lines, ["parent #{parent}"])
      end

    lines = Enum.concat(lines, ["author " <> Author.to_s(commit.author)])
    lines = Enum.concat(lines, ["committer " <> Author.to_s(commit.author)])
    lines = Enum.concat(lines, [""])
    lines = Enum.concat(lines, [commit.message])

    Enum.join(lines, "\n")
  end
end

defmodule Egit.Types.Commit do
  @moduledoc """
  An Elixir implementation of Git version control system
  """

  alias Egit.Types.Author

  defstruct tree: nil, author: nil, message: nil, oid: nil, content: nil

  def type(_commit) do
    "commit"
  end

  def to_s(commit) do
    lines = [
      "tree #{commit.tree.oid}",
      "author " <> Author.to_s(commit.author),
      "committer " <> Author.to_s(commit.author),
      "",
      commit.message
    ]

    Enum.join(lines, "\n")
  end
end

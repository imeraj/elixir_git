defmodule Egit.Types.Tree do
  @moduledoc """
  An Elixir implementation of Git version control system
  """

  @mode "100644"

  defstruct entries: nil, oid: nil, content: nil

  def type(_tree) do
    "tree"
  end

  def to_s(tree) do
    entries =
      Enum.sort_by(tree.entries, & &1.name)
      |> Enum.map(fn entry ->
        {:ok, oid} = Base.decode16(entry.oid, case: :lower)
        "#{@mode} #{entry.name}\0" <>  oid
      end)

    Enum.join(entries, "")
  end
end

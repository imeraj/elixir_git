defmodule Egit.Types.Layout do
  @moduledoc """
  An Elixir implementation of Git version control system
  """

  alias Egit.Types.{Entry, Tree}

  def add_entry([], entry, root) do
    %{root | entries: Map.put(root.entries, Entry.basename(entry.name), entry)}
  end

  def add_entry([parent | rest], entry, root) do
    tree =
      case Map.get(root.entries, Entry.basename(parent)) do
        nil -> %Tree{}
        tree -> tree
      end

    tree = add_entry(rest, entry, tree)
    %{root | entries: Map.put(root.entries, Entry.basename(parent), tree)}
  end

  def build(entries) do
    entries = Enum.sort_by(entries, & &1.name)

    Enum.reduce(entries, %Tree{}, fn entry, root ->
      add_entry(Entry.parent_dirs(entry), entry, root)
    end)
  end
end

defmodule Egit.Types.Tree do
  @moduledoc """
  An Elixir implementation of Git version control system
  """

  alias Egit.Types.Entry

  defstruct entries: %{}, oid: nil, content: nil

  def type(_tree) do
    "tree"
  end

  def to_s(tree) do
    entries =
      tree.entries
      |> Enum.map(fn {name, entry} ->
        {:ok, oid} = Base.decode16(entry.oid, case: :lower)

        case entry do
          %Egit.Types.Tree{} = _ ->
            "#{Entry.dir_mode()} #{name}\0" <> oid

          %Entry{} = entry ->
            "#{Entry.mode(entry)} #{name}\0" <> oid
        end
      end)

    Enum.join(entries, "")
  end

  def build_content(object = %Egit.Types.Tree{}) do
    string = to_s(object)
    content = "#{type(object)} #{byte_size(string)}\0#{string}"
    oid = String.downcase(:crypto.hash(:sha, content) |> Base.encode16())
    %Egit.Types.Tree{entries: object.entries, content: content, oid: oid}
  end

  def build_content(entry = %Entry{}) do
    entry
  end
end

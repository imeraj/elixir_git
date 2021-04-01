defmodule Egit.Types.BLOB do
  @moduledoc """
  An Elixir implementation of Git version control system
  """

  defstruct data: nil, oid: nil, content: nil

  def type(_blob) do
    "blob"
  end

  def to_s(blob) do
    blob.data
  end

  def build(data) do
    object = %Egit.Types.BLOB{data: data}
    string = to_s(object)
    content = "#{type(object)} #{byte_size(string)}\0#{string}"
    object = %{object | oid: String.downcase(:crypto.hash(:sha, content) |> Base.encode16())}
    %{object | content: content}
  end
end

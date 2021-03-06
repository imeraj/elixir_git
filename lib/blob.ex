defmodule Egit.BLOB do
  @moduledoc """
  An Elixir implementation of Git version control system
  """

  defstruct data: nil, oid: nil

  def type(_blob) do
    "blob"
  end

  def to_s(blob) do
    blob.data
  end
end

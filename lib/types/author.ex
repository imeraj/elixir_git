defmodule Egit.Types.Author do
  @moduledoc """
  An Elixir implementation of Git version control system
  """

  defstruct name: nil, email: nil, time: nil

  def to_s(author) do
    timestamp = "#{DateTime.to_unix(author.time)}"

    "#{author.name} <#{author.email}> " <> timestamp
  end
end

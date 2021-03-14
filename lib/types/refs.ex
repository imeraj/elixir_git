defmodule Egit.Types.Refs do
  @moduledoc """
  An Elixir implementation of Git version control system
  """

  def update_head(head_path, oid) do
    lock_path = head_path <> ".lock"

    case File.open(lock_path, [:write, :exclusive]) do
      {:ok, file} ->
        IO.binwrite(file, oid)
        File.rename(lock_path, head_path)

      {:error, :eexist} ->
        IO.puts(:stderr, "lock file exists")

      _ ->
        IO.puts(:stderr, "error creating lock file")
    end
  end

  def read_head(head_path) do
    case File.exists?(head_path) do
      true ->
        {:ok, id} = File.read(head_path)
        id

      false ->
        nil
    end
  end
end

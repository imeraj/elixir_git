defmodule Egit.Types.Index do
  @moduledoc """
  An Elixir implementation of Git version control system
  """

  alias Egit.Helpers

  defstruct entries: %{}

  def add(index, pathname, oid, stat) do
    entry = Egit.Types.Index.Entry.create(pathname, oid, stat)
    %{index | entries: Map.put(index.entries, pathname, entry)}
  end

  def write_updates(index) do
    {:ok, root_path} = File.cwd()

    index_path =
      root_path
      |> Helpers.git_path()
      |> Helpers.index_path()

    lock_path = index_path <> ".lock"

    case File.open(lock_path, [:write, :exclusive]) do
      {:ok, file} ->
        sha = begin_write()

        version = <<2::32>>
        size = <<map_size(index.entries)::32>>
        header = "DIRC" <> version <> size

        sha = write(file, header, sha)

        Enum.each(index.entries, fn {_key, entry} ->
          sha = write(file, Egit.Types.Index.Entry.to_s(entry), sha)
        end)

        finish_write(file, sha)

        File.rename(lock_path, index_path)

      {:error, :eexist} ->
        IO.puts(:stderr, "lock file exists")

      _ ->
        IO.puts(:stderr, "error creating lock file")
    end
  end

  defp begin_write() do
    :crypto.hash_init(:sha)
  end

  defp write(file, data, sha) do
    IO.binwrite(file, data)
    :crypto.hash_update(sha, data)
  end

  defp finish_write(file, sha) do
    sha = :crypto.hash_final(sha)
    IO.binwrite(file, sha)
  end

  defmodule Entry do
    use Bitwise

    @max_path_size 0xFFF
    @entry_block 8

    defstruct [
      :ctime,
      :ctime_nsec,
      :mtime,
      :mtime_nsec,
      :dev,
      :ino,
      :mode,
      :uid,
      :gid,
      :size,
      :oid,
      :flags,
      :path
    ]

    def create(path, oid, stat) do
      flags = min(byte_size(path), @max_path_size)

      %Entry{
        ctime: Helpers.datetime_to_seconds(stat.ctime),
        ctime_nsec: 0,
        mtime: Helpers.datetime_to_seconds(stat.ctime),
        mtime_nsec: 0,
        dev: stat.major_device,
        ino: stat.inode,
        mode: stat.mode,
        uid: stat.uid,
        gid: stat.gid,
        size: stat.size,
        oid: oid,
        flags: flags,
        path: path
      }
    end

    def to_s(entry) do
      {:ok, oid} = Base.decode16(entry.oid, case: :lower)

      string =
        <<entry.ctime::32>> <>
          <<entry.ctime_nsec::32>> <>
          <<entry.mtime::32>> <>
          <<entry.mtime_nsec::32>> <>
          <<entry.dev::32>> <>
          <<entry.ino::32>> <>
          <<entry.mode::32>> <>
          <<entry.uid::32>> <>
          <<entry.gid::32>> <>
          <<entry.size::32>> <> oid <> <<entry.flags::16>> <> entry.path <> <<0>>

      pad_nulls(string)
    end

    defp pad_nulls(binary) do
      rem = Integer.mod(byte_size(binary), @entry_block)
      padding = if rem == 0, do: 0, else: @entry_block - rem
      bits = padding * 8
      binary <> <<0::size(bits)>>
    end
  end
end

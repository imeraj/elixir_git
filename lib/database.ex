defmodule Egit.Database do
  @moduledoc """
  An Elixir implementation of Git version control system
  """

  alias Egit.Helpers

  def store(object) do
    unless File.exists?(object_path(object.oid)) do
      write_object(object_path(object.oid), object.content)
    end
  end

  defp object_path(oid) do
    {:ok, dir} = File.cwd()
    db_path = db_path(dir)
    Path.join([db_path, String.slice(oid, 0..1), String.slice(oid, 2..-1)])
  end

  defp write_object(object_path, content) do
    dir_name = Path.dirname(object_path)
    temp_path = Path.join([dir_name, generate_temp_name()])

    file =
      case File.open(temp_path, [:read, :write, :exclusive]) do
        {:ok, file} ->
          file

        {:error, :enoent} ->
          File.mkdir(dir_name)
          {:ok, file} = File.open(temp_path, [:read, :write, :exclusive])
          file

        _ ->
          :noop
      end

    compressed = :zlib.compress(content)
    IO.binwrite(file, compressed)
    File.close(file)

    File.rename(temp_path, object_path)
  end

  defp db_path(root_path) do
    root_path
    |> Helpers.db_path()
  end

  defp generate_temp_name() do
    "tmp_obj_#{Helpers.generate_random_string(6)}"
  end
end

defmodule Egit.Add do
  @moduledoc """
  An Elixir implementation of Git version control system
  """

  alias Egit.{Workspace, Database}
  alias Egit.Types.{BLOB, Index}

  def add(path) do
    indices =
      Enum.map(path, fn p ->
        Workspace.list_files(p)
        |> Enum.reduce(
          %Index{},
          fn file_path, index ->
            data = Workspace.read_file(file_path)
            stat = Workspace.stat_file(file_path)

            blob = BLOB.build(data)
            Database.store(blob)

            index
            |> Index.add(file_path, blob.oid, stat)
          end
        )
      end)

    entries =
      List.foldl(indices, [], fn x, acc -> acc ++ [x.entries] end)
      |> Enum.reduce(fn x, y ->
        Map.merge(x, y, fn _k, v1, v2 -> v2 ++ v1 end)
      end)

    %Index{entries: entries}
    |> Index.write_updates()
  end
end

defmodule Egit.Init do
  @moduledoc """
  An Elixir implementation of Git version control system
  """

  alias Egit.Helpers

  def init(root_path) do
    root_path
    |> Helpers.git_path()
    |> make_dirs()
  end

  defp make_dirs(git_path) do
    unless File.exists?(git_path) do
      Enum.each(["objects", "refs"], fn dir ->
        try do
          File.mkdir_p(Path.join(git_path, dir))
        rescue
          e in File.Error ->
            IO.puts(:stderr, "fatal: #{e.message}")
            exit(:fatal)
        end
      end)

      IO.puts("Initialized empty egit repository in #{git_path}")
    end
  end
end

defmodule Egit.CLI do
  @moduledoc """
  An Elixir implementation of Git version control system
  """

  def main(argv \\ []) do
    argv
    |> parse_args()
    |> process()
  end

  defp parse_args(argv) do
    argv
    |> OptionParser.parse(strict: [init: :string, commit: :string, add: :string])
    |> elem(1)
    |> args_to_internal_representation()
  end

  defp args_to_internal_representation(["init", dir]) do
    {:init, dir}
  end

  defp args_to_internal_representation(["init"]) do
    {:ok, dir} = File.cwd()
    {:init, dir}
  end

  defp args_to_internal_representation(["commit"]) do
    if File.exists?(".git") do
      {:ok, dir} = File.cwd()
      {:commit, dir}
    else
      IO.puts(:stderr, "repo not initialized")
      exit(:fatal)
    end
  end

  defp args_to_internal_representation(["add" | path]) do
    if File.exists?(".git") do
      {:add, path}
    else
      IO.puts(:stderr, "fatal: not a git repository")
      exit(:fatal)
    end
  end

  defp args_to_internal_representation(command) do
    {:help, command}
  end

  defp process({:help, _command}) do
    IO.puts(:stderr, """
    usage: egit help
           egit init [dir]
           egit commit
           egit add <filename(s)|dir(s)>
    """)
  end

  defp process({:init, dir}) do
    Egit.Init.init(dir)
  end

  defp process({:commit, dir}) do
    author = System.get_env("EGIT_AUTHOR_NAME")
    email = System.get_env("EGIT_AUTHOR_EMAIL")
    Egit.Commit.commit(dir, %{name: author, email: email})
  end

  defp process({:add, path}) do
    Egit.Add.add(path)
  end
end

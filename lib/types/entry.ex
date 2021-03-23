defmodule Egit.Types.Entry do
  @moduledoc """
  An Elixir implementation of Git version control system
  """

  use Bitwise

  @regular_mode "100644"
  @executable_mode "100755"
  @directory_mode "40000"

  defstruct name: nil, oid: nil, content: nil, stat: nil

  def parent_dirs(entry) do
    descend(entry.name)
    |> Enum.drop(-1)
  end

  def dir_mode do
    @directory_mode
  end

  def mode(entry) do
    if executable?(entry.stat.mode), do: @executable_mode, else: @regular_mode
  end

  defp executable?(mode) do
    <<_::1, _::1, o_exec::1, _::1, _::1, g_exec::1, _::1, _::1, a_exec::1>> = <<mode::9>>

    case bor(bor(o_exec, g_exec), a_exec) do
      1 -> true
      0 -> false
    end
  end

  def basename(name) do
    Path.basename(name)
  end

  defp descend(path) do
    Path.split(path)
    |> Enum.reduce([], fn dir, results ->
      case List.last(results) do
        nil ->
          [dir]

        root ->
          if root == "/" do
            results ++ [root <> dir]
          else
            results ++ [root <> "/" <> dir]
          end
      end
    end)
  end
end

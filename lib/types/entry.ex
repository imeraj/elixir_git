defmodule Egit.Types.Entry do
  @moduledoc """
  An Elixir implementation of Git version control system
  """

  use Bitwise

  @regular_mode "100644"
  @executable_mode "100755"

  defstruct name: nil, oid: nil, content: nil, stat: nil

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
end

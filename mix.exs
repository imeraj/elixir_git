defmodule Egit.MixProject do
  use Mix.Project

  def project do
    [
      app: :egit,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :crypto],
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:stream_hash, "~> 0.3.1"}
    ]
  end

  defp escript do
    [main_module: Egit.CLI]
  end
end

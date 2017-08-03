defmodule StaccaBot.Mixfile do
  use Mix.Project

  def project do
    [app: :stacca_bot,
     version: "0.1.0",
     elixir: "~> 1.4",
     default_task: "server",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     aliases: aliases()]
  end

  def application do
    [applications: [:logger, :nadia],
     mod: {StaccaBot, []}]
  end

  defp deps do
    [
      {:nadia, github: "zhyu/nadia"},
      {:tomlex, github: "zamith/tomlex"},
      {:credo, "~> 0.8", only: [:dev, :test], runtime: false}
    ]
  end

  defp aliases do
    [server: "run --no-halt"]
  end
end

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
      {:credo, "~> 0.8", only: [:dev, :test], runtime: false},
      {:httpoison, "~> 0.13.0"},
      {:nadia, github: "zhyu/nadia"},
      {:poison, "~> 3.1.0"},
      {:tomlex, github: "zamith/tomlex"}
    ]
  end

  defp aliases do
    [server: "run --no-halt"]
  end
end

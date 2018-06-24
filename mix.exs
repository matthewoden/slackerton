defmodule Slackerton.MixProject do
  use Mix.Project

  def project do
    [
      app: :slackerton,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [
        :logger, 
        :hedwig, 
        :hedwig_slack
      ],
      mod: {Slackerton.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:hedwig, "~> 1.0"},
      {:httpoison, ">= 1.2.0"},
      {:jason, "~> 1.0"},
      {:floki, "~> 0.19"},
      {:http_builder, "~> 0.4.1"},
      # {:hedwig_slack, "~> 1.0"},
      {:lex, github: "matthewoden/lex", branch: "master"},
      {:hedwig_slack, github: "matthewoden/hedwig_slack", branch: "master" },
    ]
  end
end

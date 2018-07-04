defmodule Slackerton.MixProject do
  use Mix.Project

  def project do
    [
      app: :slackerton,
      version: "0.1.0",
      elixir: "~> 1.6",
      elixirc_paths: elixirc_paths(Mix.env),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [
        :logger, 
        :timex,
        :hedwig, 
        :hedwig_slack,
        :abacus,
      ],
      mod: {Slackerton.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

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
      {:nebulex, "~> 1.0.0-rc.2"},
      {:abacus, "~> 0.4.2"},
      {:timex, "~> 3.1"},
      {:ex_aws, "~> 2.0"},
      {:ex_aws_dynamo, "~> 2.0"},
      {:hackney, ">= 1.9.0"},

    ]
  end
end

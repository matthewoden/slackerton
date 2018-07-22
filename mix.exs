defmodule Slackerton.MixProject do
  use Mix.Project

  def project do
    [
      app: :slackerton,
      version: "0.1.0",
      elixir: "~> 1.6",
      elixirc_paths: elixirc_paths(Mix.env),
      start_permanent: Mix.env() == :prod,
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Slackerton, []},
      extra_applications: [
        :logger, 
        :timex,
        :hedwig, 
        :hedwig_slack,
        :runtime_tools
      ]
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
      {:lex, github: "matthewoden/lex", branch: "master"},
      #{:hedwig_slack, path: "../hedwig_slack" },
      {:hedwig_slack, github: "matthewoden/hedwig_slack", branch: "master" },
      {:nebulex, "~> 1.0.0-rc.2"},
      {:timex, "~> 3.1"},
      {:ex_aws, "~> 2.0"},
      {:ex_aws_dynamo, "~> 2.0"},
      {:hackney, ">= 1.9.0"},
      {:sched_ex, "~> 1.0"},
      {:phoenix, "~> 1.3.3"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"}
    ]
  end

  defp aliases do
    [
      dev: ["phx.server"]
      deploy: ["cd assets", "npm run deploy", "cd ../", "phx.digest"]
    ]
  end
end

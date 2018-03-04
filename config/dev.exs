config :slackerton, Slackerton.Robot,
  adapter: Hedwig.Adapters.Slack,
  #adapter: Hedwig.Adapters.Console,
  name: "slackerton",
  aka: "/",
  token: System.get_env("MATHBEAR_SLACK_TOKEN"),
  rooms: [],
  responders: [
    {Hedwig.Responders.Help, []},
    {Slackerton.Responders.Mathbear, []},
    {Slackerton.Responders.Slap, []},
    {Slackerton.Responders.Search, []},
    {Slackerton.Responders.Rotator, []}
  ]

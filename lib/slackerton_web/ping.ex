defmodule SlackertonWeb.Ping do
  @moduledoc """
  Self-ping to keep awake at the heroku free tier.
  """
  require Logger
  import HttpBuilder

  @config Application.get_env(:slackerton, __MODULE__)
  @http Keyword.get(@config, :http_adapter)
  @json Keyword.get(@config, :json_parser, Jason)
  @base_url "https://dnd-slackbot.herokuapp.com"

  def run do
    Logger.info("Pinging Self at /api/ping")

    HttpBuilder.new()
    |> with_adapter(@http)
    |> with_json_parser(@json)
    |> with_host(@base_url)
    |> with_receive_timeout(30_000)  
    |> get("/api/ping")
    |> send()
  end
end
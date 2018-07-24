defmodule SlackertonWeb.Ping do
  require Logger

  def run do
    Logger.info("Pinging Self at /api/ping")

    HttpBuilder.new()
    |> with_adapter(@http)
    |> with_json_parser(Jason)
    |> with_host("https://dnd-slackbot.herokuapp.com")
    |> with_receive_timeout(30_000)  
    |> get("/api/ping")
    |> send()
  end
end
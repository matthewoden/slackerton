defmodule Slackerton.Weather.Api do
  import HttpBuilder
  require Logger


  @moduledoc """
  Severe Weather Alerts - https://www.weather.gov/documentation/services-web-alerts
  """

  @http Application.get_env(:slackerton, :http_adapter, HttpBuilder.Adapters.HTTPoison)
  @json Application.get_env(:slackerton, :json_parser, Jason)
  @user_agent Application.get_env(:slackerton, :user_agent)

  @base_url "https://api.weather.gov"

  def client do
    HttpBuilder.new()
    |> with_adapter(@http)
    |> with_json_parser(Jason)
    |> with_host(@base_url)
    |> with_headers(%{ 
        "User-Agent" => @user_agent, 
        "Accept" => "application/ld+json" 
      })
    |> with_receive_timeout(30_000)
  end

  def severe_weather() do
    client()
    |> get("/alerts")
    |> with_query_params(%{
      "active" => 1,
      "point" => "38.627003,-90.199402",
      "severity" => "severe",
      "urgency" => "immediate",
      "limit" => 3
    })
    |> send()
    |> parse_response()
  end

  defp parse_response({:ok, %{status_code: 200, body: body}}) do    
    alerts = @json.decode!(body) |> Map.get("@graph")
    {:ok, alerts}
  end

  defp parse_response(result) do
    Logger.error(inspect(result))
    :error
  end

end
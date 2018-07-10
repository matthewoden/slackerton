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
      "point" => "38.627003,-90.199402",
      "start" => timestamp(),
      "limit" => 1,
    })
    |> send()
    |> parse_response()
  end

  defp parse_response({:ok, %{status_code: 200, body: body}}) do    
    alert =  
      @json.decode!(body) 
      |> Map.get("@graph")
      |> Enum.map(&Map.take(&1, ["id", "headline", "description"]))
      |> Enum.at(0, %{})
      
    {:ok, alert}
  end

  defp parse_response(result) do
    Logger.error(inspect(result))
    :error
  end

  #ISO format2018-07-01T19:50:00-05:00
  defp timestamp() do
    Timex.now("America/Chicago") 
    |> Timex.subtract(Timex.Duration.from_minutes(5))
    |> Timex.format!("%Y-%m-%dT%T%z", :strftime)
  end
  

end
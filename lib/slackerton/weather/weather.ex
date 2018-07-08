defmodule Slackerton.Weather do
  alias Slackerton.Weather.Api
  alias Slackerton.Cache

  def severe_weather() do
    existing_alerts = Cache.get({__MODULE__, :alerts})
    case Api.severe_weather() do
      { :ok, [ alerts ] } ->

        formatted_alerts =
          alerts
          |> Enum.reject(fn alert -> Enum.member?(existing_alerts, alert) end)
          |> Enum.map(fn alert -> format_headline(alert) end)

        {:ok, formatted_alerts }

      _ ->
        {:error, :no_updates}
    end
  end

  def filter_alerts(new_alerts, old_alerts) do
  end

  def severe_weather_full() do
    case Cache.get({__MODULE__, :latest_alert}) do
      nil ->
        "Sorry, I don't have complete alert information at this time."

      alert ->
        format_full_alert(alert)
    end
  end

  defp format_headline(%{ "headline" => headline}) do
    """
    #{headline}

    For full alert information, ask me about severe weather.
    """
  end

  defp format_full_alert(%{ "headline" => headline, "description" => description, "areaDesc" => area }) do
    """
    #{headline}

    #{description}
    """
  end

end
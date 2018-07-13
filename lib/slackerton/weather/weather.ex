defmodule Slackerton.Weather do
  alias Slackerton.Weather.Api
  alias Slackerton.{Cache,Settings}

  @alert_settings "weather_alert"

  def severe_weather(room) do
    latest = Cache.get({__MODULE__, :latest_alert}) || %{}
    latest_id = Map.get(latest, "id")
    
    case Api.severe_weather() do
      
      { :ok, %{"id" => id } = alert } when latest_id != id ->
        Cache.set({__MODULE__, :latest_alert}, alert)

        text = format_headline(alert)
        subscribers = Settings.all(@alert_settings)

        Enum.each(subscribers, fn %{key: team, value: room} -> 
          Slackerton.Robot.broadcast(team, text, room)
        end)

        :ok
      _ ->
        {:error, :no_updates}
    end
  end

  def subscribe_channel(robot, room) do
    Settings.set(@alert_settings, robot, room)
  end

  def unsubscribe_channel(robot) do
    Settings.set(@alert_settings, robot, nil)
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

    For full alert information, ask me for the full severe weather alert.
    """
  end

  defp format_full_alert(%{ "headline" => headline, "description" => description }) do
    """
    #{headline}

    #{description}
    """
  end

end
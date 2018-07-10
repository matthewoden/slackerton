defmodule Slackerton.Weather do
  alias Slackerton.Weather.Api
  alias Slackerton.Cache

  def severe_weather(room) do
    last_id = Cache.get({__MODULE__, :last_id})
    
    case Api.severe_weather() do
      
      { :ok, %{"id" => id } = alert } when last_id != id ->
        Cache.set({__MODULE__, :latest_alert}, alert)
        Cache.set({__MODULE__, :last_id}, id)

        Slackerton.Robot.broadcast_all(format_headline(alert), room)
        :ok
        
      _ ->
        {:error, :no_updates}
    end
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
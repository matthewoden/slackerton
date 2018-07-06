defmodule Slackerton.Weather do
  alias Slackerton.Weather.Api
  alias Slackerton.Cache

  def severe_weather() do
    # Cache.get_or_else()
    case Api.severe_weather() do
      { :ok, [ alert | rest ] } ->
        Cache.set({__MODULE__, :latest_alert}, alert)
        {:ok, formatted } = format_headline(alert)
      _ ->
        {:error, :no_updates}
    end
  end

  def format_headline(%{ "headline" => headline }) do
    """
    #{headline}

    For full alert information, ask me about severe weather.
    """
  end

end
defmodule Slackerton.Weather do
  alias Slackerton.Weather.Api
  alias Slackerton.Cache

  def severe_weather() do
    # Cache.get_or_else()
    # case Api.severe_weather() do
    #   { :ok, results }
    # end
  end


  def cache_result(%{"id" => id }) do
    Cache.set("weather", "alert", id)
  end
end
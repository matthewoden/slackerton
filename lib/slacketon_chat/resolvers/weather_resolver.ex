defmodule SlackertonChat.WeatherResolver do
  require Logger
  alias Slackerton.Weather
  alias SlackertonChat.Robot
  alias Hedwig.Responder
  
  def add_alert(%{ private: %{ "robot" => robot }, room: room } = msg, _slots) do
    with {:ok, _ } <- Weather.subscribe_channel(robot, room) do
      Robot.thread(msg, "Gotcha. I'll post all weather updates in here going forward.")
    else
      otherwise -> 
        Logger.info(inspect(otherwise))
        Robot.thread(msg, "Uh, sorry. I couldn't do that.")
    end
  end

  def remove_alert(%{ private: %{ "robot" => robot } } = msg, _slots) do
    with {:ok, _ } <- Weather.unsubscribe_channel(robot) do
      Robot.thread(msg, "Understood. I'll stop posting weather updates.")
    else
      otherwise -> 
        Logger.info(inspect(otherwise))
        Robot.thread(msg, "Uh, sorry. I couldn't do that.")
    end
  end

  def detail_alert(msg, _slots) do
    Responder.reply(msg, Weather.severe_weather_full())
  end

end
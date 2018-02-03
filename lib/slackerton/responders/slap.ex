defmodule Slackerton.Responders.Slap do
   @moduledoc """
  Slap user on slack around a bit with a large trout
  `slap <username> | me
  """
  use Hedwig.Responder
  alias Slackerton.Slack

  @emoticon ":fish:"

  @usage """
  slap <username> | me - Slaps the user
  """
  hear ~r/^slap\s*me/i, msg do
    response = 
      msg.user
      |> Slack.to_user_string()
      |> trout_message

    emote msg, response
  end

  hear ~r/^slap\s*<@(?<user>\w+)>.*$/i, msg do
    response =
      msg.matches["user"]
      |> Slack.to_user_string()
      |> trout_message()

    emote msg, response
  end

  defp trout_message(user) do
    "slaps #{user} around a bit with a large trout. #{@emoticon}"
  end

end 

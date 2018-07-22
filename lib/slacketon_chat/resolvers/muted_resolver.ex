defmodule SlackertonChat.MutedResolver do
  use SlackertonChat

  alias SlackertonChat.Helpers
  alias Slackerton.Accounts.{Admin,Muted}

  def mute_user(msg, %{ "User" => user}) do
    team = Helpers.team_id(msg)
    caller = Helpers.user_id(msg.user)
    user = String.trim_leading(user, "@")

    if Admin.is_admin?(caller, team) do
      Muted.set_muted(user, team, true)
      thread(msg, "Ok, I'll ignore #{user}.")
    else
      thread(msg, Admin.reject())
    end
  end

  def mute_user(msg, _) do
    thread(msg, "Whoa, I didn't quite get the right info there.")
  end


  def unmute_user(msg, %{ "User" => user}) do
    team = Helpers.team_id(msg)
    caller = Helpers.user_id(msg.user)
    user = String.trim_leading(user, "@")

    if Admin.is_admin?(caller, team) do
      user = String.trim_leading(user, "@")
      Admin.set_admin(user, team, false)
      
      reply(msg, "Ok, I'll stop ignoring #{user}")
    else
      reply(msg, Admin.reject())
    end
  end

  def unmute_user(msg, _) do 
    reply(msg, "Whoa, I didn't quite get the right info there.")
  end


  def list_muted(msg, _) do
    muted_list =
      msg
      |> Helpers.team_id()
      |> Muted.list_muted()

    case muted_list do
      {:ok, [] } ->
        reply(msg, "There are no ignored users.")

      {:ok, list } ->
        muted_string = 
          list
          |> Enum.map(fn user -> Helpers.to_user_string(user) end)
          |> Enum.join(", ")

        reply(msg, "The ignored users on this team: #{muted_string}")

      {:error, _} ->
        reply(msg, "Sorry, I couldn't get the complete ignored list at this time.")
    end
  end

end
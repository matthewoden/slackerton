defmodule Slackerton.Accounts.UserResolver do
  alias Slackerton.{Normalize}
  alias Slackerton.Users.{Admin, Muted}
  alias Hedwig.Responder

  @rejections [
    "I'm afraid I can't let you do that.",
    "No", 
    "I don't have to listen to you, you're not my real dad!",
    "You're not an admin",
    "Hah, nice try.",
    "You wish",
    "No. Stop it.",
    "Maybe later.",
    "You'll have to ask Matt first."
  ]

  def create_admin(msg, %{ "User" => user}) do
    team = Normalize.team_id(msg)
    caller = Normalize.user_id(msg.user)
    user = String.trim_leading(user, "@")

    if Admin.is_admin?(caller, team) do
      Admin.set_admin(user, team, true)
      
      Responder.reply(msg, "Ok, I've made #{user} an admin.")
    else
      Responder.reply(msg, Enum.random(@rejections))
    end
  end

  def create_admin(msg, _) do
    Responder.reply(msg, "Whoa, I didn't quite get the right info there.")
  end


  def delete_admin(msg, %{ "User" => user}) do
    team = Normalize.team_id(msg)
    caller = Normalize.user(msg.user)
    user = String.trim_leading(user, "@")

    if Admin.is_admin?(caller, team) do
      user = String.trim_leading(user, "@")
      Admin.set_admin(user, team, false)
      
      Responder.reply(msg, "Ok, I've removed #{user} from the admin list.")
    else
      Responder.reply(msg, Enum.random(@rejections))
    end
  end

  def delete_admin(msg, _) do
    Responder.reply(msg, "Whoa, I didn't quite get the right info there.")
  end


  def list_admins(msg, _) do
    admin_list =
      msg
      |> Normalize.team_id()
      |> Admin.list_admins()

    case admin_list do
      {:ok, [] } ->
        Responder.reply(msg, "There are no admins! _No gods, no masters..._")
      {:ok, list } ->
        admin_string = 
          list
          |> Enum.map(fn user -> Normalize.to_user_string(user) end)
          |> Enum.join(", ")

        Responder.reply(msg, "The admins for this team: #{admin_string}")

      {:error, _} ->
        Responder.reply(msg, "Sorry, I couldn't get the complete admin list at this time.")
    end
  end

end
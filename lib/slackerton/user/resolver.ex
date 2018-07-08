defmodule Slackerton.UserResolver do
  alias Slackerton.{ User, Normalize}
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
    if User.is_admin?(msg.user) do
      team = Map.get(msg.private, "team", "default") 
      user = String.trim_leading(user, "@")
      User.set_admin(user, team, true)
      
      Responder.reply(msg, "Ok, I've made #{user} an admin.")
    else
      Responder.reply(msg, Enum.random(@rejections))
    end
  end

  def delete_admin(msg, %{ "User" => user}) do
    if User.is_admin?(msg.user) do
      team = get_team(msg)
      user = String.trim_leading(user, "@")
      User.set_admin(user, team, false)
      
      Responder.reply(msg, "Ok, I've removed #{user} from the admin list.")
    else
      Responder.reply(msg, Enum.random(@rejections))
    end
  end

  def list_admins(msg, _) do
    admin_list =
      msg
      |> get_team()
      |> User.list_admins()

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

  defp get_team(%{private: %{ "team" => team }}), do: team
  defp get_team(_), do: "default"

end
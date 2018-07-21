defmodule SlackertonChat.AdminResolver do
  alias SlackertonChat.Helpers
  alias Slackerton.Accounts.Admin
  alias Hedwig.Responder

  def create_admin(msg, %{ "User" => user}) do
    team = Helpers.team_id(msg)
    caller = Helpers.user_id(msg.user)
    user = String.trim_leading(user, "@")

    if Admin.is_admin?(caller, team) do
      Admin.set_admin(user, team, true)
      
      Responder.reply(msg, "Ok, I've made #{user} an admin.")
    else
      Responder.reply(msg, Admin.reject())
    end
  end

  def create_admin(msg, _) do
    Responder.reply(msg, "Whoa, I didn't quite get the right info there.")
  end


  def delete_admin(msg, %{ "User" => user}) do
    team = Helpers.team_id(msg)
    caller = Helpers.user_id(msg.user)
    user = String.trim_leading(user, "@")

    if Admin.is_admin?(caller, team) do
      user = String.trim_leading(user, "@")
      Admin.set_admin(user, team, false)
      
      Responder.reply(msg, "Ok, I've removed #{user} from the admin list.")
    else
      Responder.reply(msg, Admin.reject())
    end
  end

  def delete_admin(msg, _) do
    Responder.reply(msg, "Whoa, I didn't quite get the right info there.")
  end


  def list_admins(msg, _) do
    admin_list =
      msg
      |> Helpers.team_id()
      |> Admin.list_admins()

    case admin_list do
      {:ok, [] } ->
        Responder.reply(msg, "There are no admins! _No gods, no masters..._")
      {:ok, list } ->
        admin_string = 
          list
          |> Enum.map(fn user -> Helpers.to_user_string(user) end)
          |> Enum.join(", ")

        Responder.reply(msg, "The admins for this team: #{admin_string}")

      {:error, _} ->
        Responder.reply(msg, "Sorry, I couldn't get the complete admin list at this time.")
    end
  end

end
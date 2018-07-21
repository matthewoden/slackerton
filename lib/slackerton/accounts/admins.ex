defmodule Slackerton.Accounts.Admin do
  alias Slackerton.Accounts.User
  alias Slackerton.Repo
  require Logger

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


  def set_admin(id, team, is_admin) do
    Repo.upsert(User, %{id: id, team: team}, [
      set: [is_admin: is_admin],
      where: [not_exists: :is_super_user]
    ])
  end

  def list_admins(team \\ "default") do
    Repo.scan(User, [
      where: [is_admin: true, team: team]
    ])
  end
  
  def is_admin?(id, team) do
    case Repo.get(User, %{ id: id, team: team}) do
      %{is_admin: value} ->  
        value
      otherwise ->
        Logger.debug("#{id} was rejected as an admin: #{inspect(otherwise)}") 
        false
    end
  end

  def reject() do
    Enum.random(@rejections)
  end

  # def set_admin(id, team, is_admin) do
  #   Repo.upsert(User, %{id: id, team: team}, [
  #     expression_attribute_values: [is_admin: is_admin],
  #     update_expression: "set is_admin = :id_admin",
  #     condition_expression: "attribute_not_exists(is_super_user)"
  #   ])
  # end

  # def is_admin?(id, team) do 
  #   case Repo.get(User, %{ id: id, team: team}) do
  #     {:ok, %{is_admin: value} } ->  value
  #     _ -> false
  #   end
  # end

  # def list_admins(team \\ "default") do
  #   Repo.scan(User, "team = :team AND is_admin = :is_admin", [is_admin: true, team: team])
  # end

end
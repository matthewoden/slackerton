defmodule Slackerton.Accounts.Admin do
  alias Slackerton.Accounts.User
  alias Slackerton.Repo
  require Logger
  

  def set_admin(id, team, is_admin) do
    Repo.upsert(User, %{id: id, team: team}, [
      expression_attribute_values: [is_admin: is_admin],
      update_expression: "set is_admin = :id_admin",
      condition_expression: "attribute_not_exists(is_super_user)"
    ])
  end

  def is_admin?(id, team) do 
    case Repo.get(User, %{ id: id, team: team}) do
      {:ok, %{is_admin: value} } ->  value
      _ -> false
    end
  end

  def list_admins(team \\ "default") do
    Repo.scan(User, "team = :team AND is_admin = :is_admin", [is_admin: true, team: team])
  end

end
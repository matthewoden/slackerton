defmodule Slackerton.User do
  alias ExAws.Dynamo
  alias Slackerton.User.Repo
  require Logger
  
  @derive [Dynamo.Encodable]
  defstruct [:id, :team, :is_admin, :is_muted]

  def set_muted(id, team, is_muted) do
    Repo.upsert(%{id: id, team: team}, [
      expression_attribute_values: [is_muted: is_muted],
      update_expression: "set is_muted = :is_muted",
      condition_expression: "attribute_not_exists(is_super_user)"
    ])
  end

  def set_admin(id, team, is_admin) do
    Repo.upsert(%{id: id, team: team}, [
      expression_attribute_values: [is_admin: is_admin],
      update_expression: "set is_admin = :id_admin",
      condition_expression: "attribute_not_exists(is_super_user)"
    ])
  end

  def is_admin?(id, team) do 
    case Repo.get(id, team) do
      {:ok, %{is_admin: value} } ->  value
      _ -> false
    end
  end

  def is_muted?(id, team) do
    case Repo.get(id, team) do
      {:ok, %{is_muted: value} } ->  value
      _ -> false
    end
  end

  def list_users() do
    Repo.all()
  end

  def get(id, team) do
    Repo.get(id, team)
  end

  def list_admins(team \\ "default") do
    Repo.scan("team = :team AND is_admin = :is_admin", [is_admin: true, team: team])
  end

  def list_muted(team \\ "default") do
    Repo.scan("team = :team AND is_muted = :is_muted", [is_muted: true, team: team])
  end

end
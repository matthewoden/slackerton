defmodule Slackerton.Accounts.Muted do
  alias ExAws.Dynamo
  alias Slackerton.Accounts.User
  require Logger
  
  def set_muted(id, team, is_muted) do
    Repo.upsert(User, %{id: id, team: team}, [
      expression_attribute_values: [is_muted: is_muted],
      update_expression: "set is_muted = :is_muted",
      condition_expression: "attribute_not_exists(is_super_user)"
    ])
  end

  def is_muted?(id, team) do
    case Repo.get(User, %{ id: id, team: team}) do
      {:ok, %{is_muted: value} } ->  value
      _ -> false
    end
  end

  def list_muted(team \\ "default") do
    Repo.scan("team = :team AND is_muted = :is_muted", [is_muted: true, team: team])
  end

end
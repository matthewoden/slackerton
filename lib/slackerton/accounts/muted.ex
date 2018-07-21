defmodule Slackerton.Accounts.Muted do
  alias Slackerton.Accounts.User
  alias Slackerton.Repo
  require Logger
  
  def set_muted(id, team, is_muted) do
    Repo.upsert(User, %{id: id, team: team}, [
      set: [is_muted: is_muted],
      where: [not_exists: :is_super_user]
    ])
  end

  def list_muted(team \\ "default") do
    Repo.scan(User, [
      where: [is_muted: true, team: team]
    ])
  end

  def is_muted?(id, team) do
    case Repo.get(User, %{ id: id, team: team}) do
      %{is_muted: value} ->  value
      _ -> false
    end
  end

end
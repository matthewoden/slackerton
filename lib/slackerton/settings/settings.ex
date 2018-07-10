defmodule Slackerton.Settings do
  alias Slackerton.Settings.Setting
  alias Slackerton.Repo
  require Logger
  
  def get(team, key) do
    case Repo.get(Setting, %{team: team, key: key}) do
      nil -> nil
      value -> Jason.decode!(value)
    end
  end

  def set(team, key, value) do
    encoded_value = Jason.encode!(value)
    Repo.upsert(Setting, %{team: team, key: key }, [
      expression_attribute_names: %{ "#val" => "value"},
      expression_attribute_values: [ value: encoded_value ],
      update_expression: "set #val = :value"
    ])
  end

  def list_settings(team) do
    Repo.scan(Setting, "team = :team", [team: team])
  end
end


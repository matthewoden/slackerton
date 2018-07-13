defmodule Slackerton.Settings do
  alias Slackerton.Settings.Setting
  alias Slackerton.Repo
  require Logger
  
  def get(service, key) do
    case Repo.get(Setting, %{service: service, key: key}) do
      nil -> nil
      value -> Jason.decode!(value)
    end
  end

  def set(service, key, value) do
    with {:ok, encoded_value } <- Jason.encode(value) do
      Repo.upsert(Setting, %{service: service, key: key }, [
        expression_attribute_names: %{ "#val" => "value"},
        expression_attribute_values: [ value: encoded_value ],
        update_expression: "set #val = :value"
      ])

    else
      otherwise -> 
        IO.inspect(otherwise)
        otherwise
    end
  end

  def all(service) do
    Repo.scan(Setting, "service = :service", [service: service])
  end

end


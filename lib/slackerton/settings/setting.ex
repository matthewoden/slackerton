defmodule Slackerton.Settings.Setting do
  alias ExAws.Dynamo
  alias Slackerton.Cache

  @derive [Dynamo.Encodable]
  defstruct [:team, :key, :value]

  def table(),  do: "Settings"

  def decode(item), do: Dynamo.decode_item(item, as: __MODULE__) |> cache()
  
  defp cache(item), do: Cache.set({__MODULE__, %{team: item.team, key: item.key }}, item.value)

end

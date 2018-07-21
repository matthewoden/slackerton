defmodule Slackerton.Accounts.User do
  alias ExAws.Dynamo
  alias Slackerton.Cache
  require Logger
  
  @derive [Dynamo.Encodable]
  defstruct [:id, :team, :is_admin, :is_muted]

  @indexes [:is_admin, :is_muted]

  def table(), do: "Users"

  def decode(user) do
    Dynamo.decode_item(user, as: __MODULE__) |> cache()
  end

  defp cache(user) do
    key = %{ id: user.id, team: user.team }

    Cache.set({__MODULE__, key}, user)
    Enum.each(@indexes, 
      fn index -> 
        if Map.get(user, index) do
          Cache.update({__MODULE__, index}, MapSet.new([key]), &MapSet.put(&1, key))
        else
          Cache.update({__MODULE__, index}, MapSet.new(), &MapSet.delete(&1, key))
        end
      end)

    user
  end

end

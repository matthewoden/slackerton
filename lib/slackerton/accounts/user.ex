defmodule Slackerton.Accounts.User do
  alias ExAws.Dynamo
  alias Slackerton.{User, Cache}
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

  # not used, yet
  # def query(statement, params) do
  #   options = [
  #     expression_attribute_values: params, 
  #     key_condition_expression: statement
  #   ]
  #   request = Dynamo.query("Users", options) |> ExAws.request

  #   case request do
  #     {:ok, result } -> 
  #       Logger.debug(inspect(result))
  #       users = Enum.map(result, fn user -> Dynamo.decode_item(user, as: __MODULE__) |> cache end)
  #       {:ok, users }

  #     {:error, result } ->
  #       Logger.debug(inspect(result))

  #       {:error, result }
  #   end
  # end



  # def scan(statement, params) do
  #   options = [
  #     expression_attribute_values: params, 
  #     filter_expression: statement
  #   ]
  #   request = Dynamo.scan("Users", options) |> ExAws.request

  #   case request do
  #     {:ok, %{ "Items" => items } = result } -> 
  #       Logger.debug(inspect(result))
  #       users = Enum.map(items, fn user -> Dynamo.decode_item(user, as: __MODULE__) |> cache end)
  #       {:ok, users }

  #     {:error, result } ->
  #       Logger.debug(inspect(result))

  #       {:error, result }
  #   end
  # end

  # def get(id, team) do    
  #   Cache.get_or_else({User, id}, fn -> get_remote(id, team) end)
  # end

  # defp get_remote(id, team) do
  #   with {:ok, result } <- Dynamo.get_item("Users", %{ id: id, team: team }) |> ExAws.request do
  #     Logger.error(inspect(result))

  #     user = Dynamo.decode_item(result, as: __MODULE__ ) |> cache()
  #     {:ok, user }
  #   else
  #     {:error, result} ->
  #       Logger.error(inspect(result))

  #       {:error, result}
  #   end
  # end


  # def all() do
  #   with {:ok, %{ "Items" => result } } <- Dynamo.scan("Users", [select: :all_attributes]) |> ExAws.request do
  #     Logger.debug(inspect(result))

  #     users = 
  #       Enum.map(result, fn user -> 
  #         Dynamo.decode_item(user, as: __MODULE__) |> cache()
  #       end)
      
  #     { :ok, users }
  #   else
  #     {:error, result} -> 
  #       Logger.error(inspect(result))

  #       {:error, result}
  #   end
  # end

  # def upsert(id, query) do
  #   options = Enum.concat(query, [return_values: :all_new])
  #   request = Dynamo.update_item("Users", id, options) |> ExAws.request

  #   case request do
  #     {:ok, result } -> 
  #       Logger.debug(inspect(result))

  #       user = result["Attributes"] |> Dynamo.decode_item(as: __MODULE__) |> cache()
  #       { :ok, user }

  #     {:error, result} ->
  #       Logger.error(inspect(result))

  #       {:error, result}
  #   end
  # end
end

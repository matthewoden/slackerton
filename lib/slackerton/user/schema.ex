defmodule Slackerton.User.Repo do
  alias ExAws.Dynamo
  alias Slackerton.{User, Cache}

  require Logger
  
  @derive [Dynamo.Encodable]
  defstruct [:id, :team, :is_admin, :is_muted]
  @indexes [:is_admin, :is_muted]

  # not used, yet
  def query(statement, params) do
    options = [
      expression_attribute_values: params, 
      key_condition_expression: statement
    ]
    request = Dynamo.query("Users", options) |> ExAws.request

    case request do
      {:ok, result } -> 
        Logger.debug(inspect(result))
        users = Enum.map(result, fn user -> Dynamo.decode_item(user, as: __MODULE__) |> cache end)
        {:ok, users }

      {:error, result } ->
        Logger.debug(inspect(result))

        {:error, result }
    end
  end

  defp cache(user) do
    Cache.set({User, user.id}, user)

    Enum.each(@indexes, 
      fn index -> 
        if Map.get(user, index) do
          Cache.update({User, index}, MapSet.new([user.id]), &MapSet.put(&1, user.id))
        else
          Cache.update({User, index}, MapSet.new(), &MapSet.delete(&1, user.id))
        end
      end)

    user
  end

  def scan(statement, params) do
    options = [
      expression_attribute_values: params, 
      filter_expression: statement
    ]
    request = Dynamo.scan("Users", options) |> ExAws.request

    case request do
      {:ok, %{ "Items" => items } = result } -> 
        Logger.debug(inspect(result))
        users = Enum.map(items, fn user -> Dynamo.decode_item(user, as: __MODULE__) |> cache end)
        {:ok, users }

      {:error, result } ->
        Logger.debug(inspect(result))

        {:error, result }
    end
  end

  def get(id, team) do    
    Cache.get_or_else({User, id}, fn -> get_remote(id, team) end)
  end

  defp get_remote(id, team) do
    with {:ok, result } <- Dynamo.get_item("Users", %{ id: id, team: team }) |> ExAws.request do
      Logger.error(inspect(result))

      user = Dynamo.decode_item(result, as: __MODULE__ ) |> cache()
      {:ok, user }
    else
      {:error, result} ->
        Logger.error(inspect(result))

        {:error, result}
    end
  end


  def all() do
    with {:ok, %{ "Items" => result } } <- Dynamo.scan("Users", [select: :all_attributes]) |> ExAws.request do
      Logger.debug(inspect(result))

      users = 
        Enum.map(result, fn user -> 
            user = Dynamo.decode_item(user, as: __MODULE__) |> cache()
        end)
      
      { :ok, users }
    else
      {:error, result} -> 
        Logger.error(inspect(result))

        {:error, result}
    end
  end

  def upsert(id, query) do
    options = Enum.concat(query, [return_values: :all_new])
    request = Dynamo.update_item("Users", id, options) |> ExAws.request

    case request do
      {:ok, result } -> 
        Logger.debug(inspect(result))

        user = result["Attributes"] |> Dynamo.decode_item(as: __MODULE__) |> cache()
        { :ok, user }

      {:error, result} ->
        Logger.error(inspect(result))

        {:error, result}
    end
  end
end

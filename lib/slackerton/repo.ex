defmodule Slackerton.Repo do
  alias ExAws.Dynamo
  alias Slackerton.Cache

  require Logger

  def scan(mod, statement, params) do
    options = [
      expression_attribute_values: params, 
      filter_expression: statement
    ]
    request = Dynamo.scan(mod.table(), options) |> ExAws.request

    case request do
      {:ok, %{ "Items" => items } = result } -> 
        Logger.debug(inspect(result))
        
        {:ok, Enum.map(items, fn (item) -> mod.decode(item) end) }

      {:error, result } ->
        Logger.debug(inspect(result))

        {:error, result }
    end
  end

  def get(mod, key) do    
    Cache.get({mod, key})
  end

  def get_remote(mod, key) do
    Dynamo.get_item(mod.table(), key) |> ExAws.request
  end

  def all(mod) do
    with {:ok, %{ "Items" => result } } <- Dynamo.scan(mod.table(), [select: :all_attributes]) |> ExAws.request do
      Logger.debug(inspect(result))

      { :ok, Enum.map(result, fn item -> mod.decode(item) end) }
    else
      {:error, result} -> 
        Logger.error(inspect(result))

        {:error, result}
    end
  end

  def upsert(mod, id, query) do
    options = Enum.concat(query, [return_values: :all_new])
    request = Dynamo.update_item(mod.table(), id, options) |> ExAws.request

    case request do
      {:ok, result } -> 
        Logger.debug(inspect(result))
        item = result["Attributes"] |> mod.decode()
        { :ok, item }

      {:error, result} ->
        Logger.error(inspect(result))

        {:error, result}
    end
  end

  def delete(mod, key) do
    Cache.delete({mod, key})
    Dynamo.delete_item(mod.table(), key) |> ExAws.request
  end

end

defmodule Slackerton.Repo.Dynamo do
  alias ExAws.Dynamo
  alias Slackerton.Cache
  require Logger

  def scan(mod, params) do
    where = Keyword.get(params, :where, []) |> IO.inspect

    filter_expression = 
      where
      |> Enum.map(fn {key, _} -> "#{key} = :#{key}" end) 
      |> Enum.join(" AND ")
      |> if_not_empty(fn string -> string end)


    options = [
      expression_attribute_values: where, 
      filter_expression: filter_expression
    ] |> IO.inspect
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
    params = Keyword.get(query, :set, [])
    condition = Keyword.get(query, :where, [])

    update_expression = 
      params
      |> Enum.map(fn {key, _} -> "#{key} = :#{key}" end) 
      |> Enum.join(", ")
      |> if_not_empty(fn string -> "set #{string}" end)

    condition_expression = 
      condition
      |> Enum.map(fn
          {:not_exists, key} -> "attribute_not_exists(#{key})"
          _ -> nil
         end)
      |> Enum.filter(fn v -> v end)
      |> Enum.join(", ")
      |> if_not_empty(fn v -> v end)
    
    options = [
      expression_attribute_values: params,
      update_expression: update_expression,
      condition_expression: condition_expression,
      return_values: :all_new
    ] 
    |> Enum.filter(fn {_key, val} -> val != nil  end)

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

  defp if_not_empty("", _fun), do: nil
  defp if_not_empty(string, fun), do: fun.(string)

  def delete(mod, key) do
    Cache.delete({mod, key})
    Dynamo.delete_item(mod.table(), key) |> ExAws.request
  end

end

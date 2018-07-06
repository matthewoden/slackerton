defmodule Slackerton.Persisted do
  @moduledoc """
  Dynamo is just for basic persistence. 
  
  Use a basic genserver to handle rate-limited read/write ops.
  """
  use GenServer


  def start_link(_) do
    state = %{"Users" => [], "DayCache" => []}
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end

  def put_item(table, item) do
    Genserver.call(__MODULE__, :write, table, item)
  end

  def delete_item(table, item) do
    Genserver.call(__MODULE__, :delete, table, item)
  end

  def get_item(table, lookup) do
    Dynamo.get_item(table, lookup) |> ExAws.request! |> Map.get("Item")
  end

  def query(table, options) do
    options = 
      [
        limit: options.limit,
        expression_attribute_values: options.params,
        key_condition_expression: options.expression,
      ] 
      |> Enum.filter(
          fn
            ({k, nil}) -> false 
            _ -> true
          end
        )

    Dynamo.query(table, options)
  end


  #
  # Callbacks
  ######


  defp schedule_write(table) do
    Process.send_after(self(), {:do_write, table}, 1010)
  end

  def handle_info({ :do_write, table }, state) do
    schedule_write(table)

    [ batch | keep ] = 
      state
      |> Map.get(table, [])
      |> Enum.map(fn table -> Enum.chunk_every(table, 25) end)
      
    Dynamo.batch_write_item(batch) |> ExAws.request!

    {:noreply, Map.put(state, table, keep)}
  end

  def handle_call({:write, table, item }, _from, state) do
    {:noreply, push(state, :write_request, table, item) }
  end

  def handle_call({:delete, table, item }, _from, state) do
    {:noreply, push(state, :delete_request, table, item) }
  end

  defp push(state, op, table, item) do
    Map.update(
      state, 
      table, 
      [ {op, [{ :item, item }]} ],
      fn state -> [{op, [{ :item, item }]} | state ] end
    )
  end
end
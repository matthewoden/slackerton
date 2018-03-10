defmodule Slackerton.Brain.ProcessStore do
  
  @behaviour Slackerton.Brain.Store

  use Agent

  def start_link(_arg) do
    Agent.start_link(fn -> Map.new end, name: __MODULE__)
  end

  def get(key) do
    Agent.get(__MODULE__, &Map.get(&1, key))
  end

  def add(key, value) do
    Agent.update(__MODULE__, &Map.put(&1, key, value))
  end

  def update(key, fun) do
    Agent.update(__MODULE__, &Map.update!(&1, key, fun))
  end

  def remove(key) do
    Agent.update(__MODULE__, &Map.delete(&1, key))
  end
  
end
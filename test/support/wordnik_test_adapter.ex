defmodule Slackerton.Adapters.WordnikTest do
  
  @cat_defined File.read!("./test/fixtures/cat.defined.json")
    
  def send(%{path: "/cat/definitions"}) do
    {:ok, %{status_code: 200, body: File.read!("./test/fixtures/cat.defined.json")} }
  end

  def send(%{path: "/asdf/definitions"}) do
    {:ok, %{status_code: 200, body: "[]"} }
  end


  def send(%{path: "/cat/audio"}) do
    {:ok, %{status_code: 200, body: File.read!("./test/fixtures/cat.pronounced.json")} }
  end
  
  def send(%{path: "/asdf/audio"}) do
    {:ok, %{status_code: 200, body: "[]"} }
  end

  def send(%{path: "/asdf/topExample"}) do
    {:ok, %{status_code: 404, body: "[]"} }
  end

  def send(%{path: "/cat/topExample"}) do
    {:ok, %{status_code: 200, body: File.read!("./test/fixtures/cat.example.json")} }
  end

end

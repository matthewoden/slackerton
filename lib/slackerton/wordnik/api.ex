defmodule Slackerton.Wordnik.Api do
  import HttpBuilder
  require Logger

  @config Application.get_env(:slackerton, __MODULE__)
  @http Keyword.get(@config, :http_adapter)
  @json Keyword.get(@config, :json_parser, Jason)
  @api_key Keyword.get(@config, :wordnik_key)

  @base_url "https://api.wordnik.com/v4/word.json"

  def client() do
    HttpBuilder.new()
    |> with_adapter(@http)
    |> with_json_parser(Jason)
    |> with_host(@base_url)
    |> with_query_params(%{
        "api_key" => @api_key,
      })
    |> with_receive_timeout(30_000)
  end

  @spec define(String.t) :: {:ok, list } | {:error, :atom }
  def define(word) do
    request = 
      client()
      |> get("/#{word}/definitions")
      |> with_query_params(%{
        "limit" => 3,
        "includeRelated" => false,
        "sourceDictionaries" => "all",
        "useCanonical" => "true",
        "includeTags" => "false"
      })
      |> send()

    case request do
      {:ok, %{status_code: 200, body: "[]"}} ->
        {:error, :unknown_word }

      {:ok, %{status_code: 200, body: body}} ->
        {:ok, @json.decode!(body) }

      result ->
        Logger.error(result)
        {:error, :other}
    end
   end

   @spec pronounce(String.t) :: {:ok, list } | {:error, :atom }
   def pronounce(word) do
    request = 
      client()
      |> get("/#{word}/audio")
      |> with_query_params(%{
        "limit" => 1,
        "useCanonical" => "true",
      })
      |> send()

    case request do
      {:ok, %{status_code: 200, body: "[]"}} ->
        {:error, :unknown_word }

      {:ok, %{status_code: 200, body: body}} ->
        {:ok, @json.decode!(body) |> Enum.at(0) }

      result ->
        Logger.error(result)
        {:error, :other}
    end
   end

   @spec example(String.t) :: {:ok, map() } | {:error, :atom }
   def example(word) do
    request = 
      client()
      |> get("/#{word}/topExample")
      |> with_query_params(%{
        "useCanonical" => "true",
      })
      |> send()

    case request do
      {:ok, %{status_code: 200, body: body}} ->
        {:ok, @json.decode!(body) }

      {:ok, %{status_code: 404, body: _}} ->
        {:error, :unknown_word }

      result ->
        Logger.error(result)
        {:error, :other}
    end
  end

end
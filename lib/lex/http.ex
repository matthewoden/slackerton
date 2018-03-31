defmodule Lex.Http do
  import HttpBuilder

  @config Application.get_env(:slackerton, Lex)
  @region Keyword.get(@config, :region)
  @model "https://models.lex.#{@region}.amazonaws.com"
  @runtime "https://runtime.lex.#{@region}.amazonaws.com"

  @access_key_id Keyword.get(@config, :aws_access_key_id)
  @secret_access_key Keyword.get(@config, :aws_secret_access_key)
  @http Application.get_env(:slackerton, :http_adapter, HttpBuilder.Adapters.HTTPoison)
  @json Application.get_env(:slackerton, :json_parser, Jason)

  defp client(:runtime) do
    HttpBuilder.new()
    |> with_adapter(@http)
    |> with_host(@runtime)
    |> with_json_parser(@json)
  end

  defp client(:model) do
    HttpBuilder.new()
    |> with_adapter(@http)
    |> with_host(@model)
    |> with_json_parser(@json)
  end

  @doc """
  Posts text to the configured AWS runtime endpoint
  """
  def post_text(%Lex.Runtime.Request{} = request) do
    post_text(request, 0)
  end

  defp post_text(%Lex.Runtime.Request{} = request, 3) do
    Lex.Runtime.Response.Error.cast(request.user_id, {:error, :too_many_retries })
  end

  defp post_text(%Lex.Runtime.Request{} = request, retries) do
    body = %{ "inputText" => request.input }
    body = if request.session_attributes, do: Map.put(body, "sessionAttributes", request.session_attributes), else: body
    body = if request.request_attributes, do: Map.merge(body, "requestAttributes", request.request_attributes), else: body

    user_id = "#{request.bot_alias}_#{request.user_id}_#{request.context}"

    aws_request =
      client(:runtime)
      |> post("/bot/#{request.bot_name}/alias/#{request.bot_alias}/user/#{user_id}/text")
      |> with_json_body(body)
      |> sign_request()
      |> send()
      |> IO.inspect()

    case parse_response(aws_request) do
      {:ok, body } ->
        Lex.Runtime.Response.cast(request.user_id, request.context, body)

      {:error, { :internal_server_error, _body } } ->
        post_text(request, retries + 1)

      {:error, result } ->
        Lex.Runtime.Response.Error.cast(request.user_id, result)
    end

  end

  defp sign_request(request) do
    body = elem(request.body,1) |> @json.encode!()
    url = "#{request.host}#{request.path}"
    headers = Map.new(request.headers)
    method = cast_method(request.method)

   headers = AWSAuth.sign_authorization_header(
      @access_key_id,
      @secret_access_key, 
      method, 
      url, 
      @region, 
      "lex", 
      headers,
      body
    )

    HttpBuilder.with_headers(request, headers)
  end

  defp cast_method(:get), do: "GET"
  defp cast_method(:post), do: "POST"
  defp cast_method(:put), do: "PUT"
  defp cast_method(:patch), do: "PATCH"

  defp parse_response({:ok, %{status_code: 200, body: body}}) do
    {:ok, @json.decode!(body)}
  end

  defp parse_response({ :ok, %{status_code: 502}  = request}) do
    {:error, {:bad_gateway, request } }
  end

  defp parse_response({ :ok, %{status_code: 400 } = request }) do
    {:error, {:bad_request, request} }
  end

  defp parse_response({ :ok, %{status_code: 409 } = request }) do
    {:error, {:conflict, request} }
  end

  defp parse_response({ :ok, %{status_code: 500,}  = request}) do
    {:error, {:internal_server_error, request } }
  end

  defp parse_response({ :ok, %{status_code: 429 } = request }) do
    {:error, {:too_many_requests, request} }
  end

  defp parse_response({ :ok, %{status_code: 404 } = request }) do
    {:error, {:not_found, request} }
  end

  defp parse_response({ :ok, response }) do
    {:error, {:unknown, response } }
  end

  defp parse_response(response) do
    {:error, {:unknown, response } }
  end

end
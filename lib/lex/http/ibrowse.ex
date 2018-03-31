defmodule Lex.Http.IBrowse do

  def adapter(), do: HttpBuilder.Adapters.IBrowse

  def parse_response do
    
  end
end

defmodule Lex.Http.Hackney do

  def adapter(), do: HttpBuilder.Adapters.Hackney

  def parse_response do
    
  end

end

defmodule Lex.Http.HTTPoison do

  @json Jason
  def adapter(), do: HttpBuilder.Adapters.HTTPoison

  def parse_response({:ok, %{status_code: 200, body: body}}) do
    {:ok, @json.decode!(body)}
  end

  def parse_response({ :ok, %{status_code: 502, body: body} }) do
    {:error, {"BadGatewayException", body } }
  end

  def parse_response({ :ok, %{status_code: 400, body: body } }) do
    {:error, {"BadRequestException", body} }
  end

  def parse_response({ :ok, %{status_code: 409, body: body } }) do
    {:error, {"ConflictException", body} }
  end

  def parse_response({ :ok, %{status_code: 500,  body: body} }) do
    {:error, {"InternalFailureException", body } }
  end

  def parse_response({ :ok, %{status_code: 429, body: body } }) do
    {:error, {"LimitExceededException", body} }
  end

  def parse_response({ :ok, %{status_code: 404, body: body } }) do
    {:error, {"NotFoundException", body} }
  end

  def parse_response({ :ok, response }) do
    {:error, response }
  end

  def parse_response(response) do
    {:error, response }
  end

end

defmodule Lex.Http.HTTPotion do
  
  @json Jason

  def adapter(), do: HttpBuilder.Adapters.HTTPotion

  def parse_response({:ok, %{status_code: 200, body: body}}) do
    {:ok, @json.decode!(body)}
  end

  def parse_response({ :ok, %{status_code: 502, body: body} }) do
    {:error, {"BadGatewayException", body } }
  end

  def parse_response({ :ok, %{status_code: 400, body: body } }) do
    {:error, {"BadRequestException", body} }
  end

  def parse_response({ :ok, %{status_code: 409, body: body } }) do
    {:error, {"ConflictException", body} }
  end

  def parse_response({ :ok, %{status_code: 500,  body: body} }) do
    {:error, {"InternalFailureException", body } }
  end

  def parse_response({ :ok, %{status_code: 429, body: body } }) do
    {:error, {"LimitExceededException", body} }
  end

  def parse_response({ :ok, %{status_code: 404, body: body } }) do
    {:error, {"NotFoundException", body} }
  end

  def parse_response({ :ok, response }) do
    {:error, response }
  end

  def parse_response(response) do
    {:error, response }
  end

end
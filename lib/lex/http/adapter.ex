defmodule Lex.Http.Adapter do

  @type request :: Lex.Runtime.Request.t
  @type json :: map() | list()
  @type error :: :bad_gateway | :bad_request | :conflict | 
    :internal_server_error | :too_many_requests | :not_found | :unknown 

  @type response :: { :ok, json } | {:error, { error, term() } }

  @callback adapter :: module()

  @callback parse_response(request) :: response

end
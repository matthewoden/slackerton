defmodule SlackertonChat.Lex.Router do
  defmacro __using__(_opts) do
    quote do
      import SlackertonChat.Lex.Router

      Module.register_attribute __MODULE__, :lex_route, accumulate: true

      @before_compile SlackertonChat.Lex.Router
    end
  end

  defmacro resolve(intent, mod, fun) do
    quote do
      @lex_route {unquote(intent), unquote(mod), unquote(fun)}
    end
  end


  defmacro __before_compile__(_env) do
    quote location: :keep do

      def dispatch(intent, msg, slots \\ %{}) do
        dispatch_resolvers(intent, msg, slots, @lex_route)
      end

      defp dispatch_resolvers(intent, msg, slots, routes) do
        Enum.each routes, 
          fn
            {^intent, mod, fun} -> apply(mod, fun, [msg, slots]) 
            _ -> :ok
          end
      end
    end
  end
end
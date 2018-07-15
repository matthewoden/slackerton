defmodule SlackertonChat.Router do
  use SlackertonChat.Lex.Router
  alias SlackertonChat.{NewsResolver, DadJokesResolver, GithubResolver, 
          TriviaResolver, WikipediaResolver, WeatherResolver, WordnikResolver}

  resolve "DadJokes", DadJokesResolver, :tell_joke
  resolve "TriviaGame", TriviaResolver, :start_game
  resolve "GetNews", NewsResolver, :latest_news
  resolve "SummarizeTopic", WikipediaResolver, :summarize

  resolve "DefineWord", WordnikResolver, :define_word
  resolve "PronounceWord", WordnikResolver, :pronounce_word
  resolve "ExampleWord", WordnikResolver, :example_word

  resolve "AddAdmin", UserResolver, :create_admin
  resolve "RemoveAdmin", UserResolver, :delete_admin
  resolve "ListAdmin", UserResolver, :list_admins

  resolve "AddSevereWeatherAlert", WeatherResolver, :add_alert
  resolve "RemoveSevereWeatherAlert", WeatherResolver, :remove_alert
  resolve "DetailSevereWeather", WeatherResolver, :detail_alert

  resolve "SuggestFeature", GithubResolver, :feature_request

end
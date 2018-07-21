defmodule SlackertonChat.Router do
  use SlackertonChat.Lex.Router
  alias SlackertonChat.{AdminResolver, MutedResolver, NewsResolver, DadJokesResolver, GithubResolver, 
          TriviaResolver, WikipediaResolver, WeatherResolver, WordnikResolver}

  resolve "DadJokes", DadJokesResolver, :tell_joke
  resolve "TriviaGame", TriviaResolver, :start_game
  resolve "GetNews", NewsResolver, :latest_news
  resolve "SummarizeTopic", WikipediaResolver, :summarize

  resolve "DefineWord", WordnikResolver, :define_word
  resolve "PronounceWord", WordnikResolver, :pronounce_word
  resolve "ExampleWord", WordnikResolver, :example_word

  resolve "AddAdmin", AdminResolver, :create_admin
  resolve "RemoveAdmin", AdminResolver, :delete_admin
  resolve "ListAdmin", AdminResolver, :list_admins

  resolve "MuteUser", MutedResolver, :mute_user
  resolve "UnmuteUser", MutedResolver, :unmute_user
  resolve "ListMuted", MutedResolver, :list_muted

  resolve "AddSevereWeatherAlert", WeatherResolver, :add_alert
  resolve "RemoveSevereWeatherAlert", WeatherResolver, :remove_alert
  resolve "DetailSevereWeather", WeatherResolver, :detail_alert

  resolve "SuggestFeature", GithubResolver, :feature_request

end
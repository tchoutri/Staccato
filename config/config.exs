use Mix.Config

config :stacca_bot,
  bot_name: "foobar"

config :nadia,
  token: {:system, "TELEGRAM_TOKEN", "default_value_if_needed"}


import_config "#{Mix.env}.exs"

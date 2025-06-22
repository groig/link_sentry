import Config

config :link_sentry, LinkSentry.Repo,
  database: "link_sentry.db",
  pool_size: 5

config :link_sentry,
  ecto_repos: [LinkSentry.Repo],
  check_interval: 60_000

config :telegex,
  token: System.get_env("TELEGRAM_BOT_TOKEN") || "your_bot_token_here"

defmodule LinkSentry.Repo do
  use Ecto.Repo,
    otp_app: :link_sentry,
    adapter: Ecto.Adapters.SQLite3
end

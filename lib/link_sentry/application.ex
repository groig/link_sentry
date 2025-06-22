defmodule LinkSentry.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      LinkSentry.Repo,
      {Finch, name: LinkSentryFinch},
      LinkSentry.Bot,
      LinkSentry.MonitorWorker
    ]

    opts = [strategy: :one_for_one, name: LinkSentry.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

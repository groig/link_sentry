defmodule LinkSentry.MonitorWorker do
  use GenServer
  alias LinkSentry.{Links, Monitor}
  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    schedule_check()
    {:ok, %{}}
  end

  def handle_info(:check_links, state) do
    check_all_links()
    schedule_check()
    {:noreply, state}
  end

  defp schedule_check do
    interval = Application.get_env(:link_sentry, :check_interval, 60_000)
    Process.send_after(self(), :check_links, interval)
  end

  defp check_all_links do
    links = Links.get_all_active_links()
    Logger.info("Checking #{length(links)} links")

    Enum.each(links, fn link ->
      Task.start(fn -> Monitor.check_link(link) end)
    end)
  end
end

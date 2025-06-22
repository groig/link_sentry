defmodule LinkSentry.Notifications do
  require Logger

  def notify_user(user, message) do
    case Telegex.send_message(user.telegram_id, message) do
      {:ok, _} ->
        Logger.info("Notification sent to user #{user.telegram_id}")

      {:error, reason} ->
        Logger.error("Failed to send notification to user #{user.telegram_id}: #{inspect(reason)}")
    end
  end
end

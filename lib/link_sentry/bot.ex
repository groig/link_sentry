defmodule LinkSentry.Bot do
  use Telegex.Polling.GenHandler
  alias LinkSentry.{Users, Links}
  require Logger

  @impl true
  def on_boot do
    Logger.info("Starting LinkSentry Bot...")

    # Delete any potential webhook
    case Telegex.delete_webhook() do
      {:ok, true} -> Logger.info("Webhook deleted successfully")
      {:ok, false} -> Logger.info("No webhook to delete")
      {:error, reason} -> Logger.error("Failed to delete webhook: #{inspect(reason)}")
    end

    # Test the bot token
    case Telegex.get_me() do
      {:ok, bot_info} ->
        Logger.info("Bot connected successfully: #{bot_info.username}")

      {:error, reason} ->
        Logger.error("Failed to connect to Telegram: #{inspect(reason)}")
    end

    # Return polling configuration
    %Telegex.Polling.Config{
      timeout: 30,
      allowed_updates: ["message"]
    }
  end

  @impl true
  def on_update(update) do
    Logger.info("Received update: #{inspect(update, limit: :infinity)}")
    handle_update(update)
    :ok
  end

  defp handle_update(%{message: %{text: text, from: from, chat: %{id: chat_id}}} = _update) do
    Logger.info("Processing message: #{text} from user #{from.id}")
    {:ok, user} = Users.find_or_create_user(from)

    case parse_command(text) do
      {:start} ->
        send_message(chat_id, """
        Welcome to LinkSentry! 🔗

        Commands:
        /add <url> [name] - Add a link to monitor
        /list - Show your monitored links
        /remove <id> - Remove a link
        /help - Show this help
        """)

      {:add, url, name} ->
        handle_add_link(chat_id, user, url, name)

      {:list} ->
        handle_list_links(chat_id, user)

      {:remove, link_id} ->
        handle_remove_link(chat_id, user, link_id)

      {:help} ->
        send_message(chat_id, """
        LinkSentry Bot Commands:

        /add <url> [name] - Add a URL to monitor
        Example: /add https://example.com My Site

        /list - Show all your monitored links
        /remove <id> - Remove a link by ID
        /help - Show this help message

        You can monitor up to 5 links. Links are checked every minute.
        """)

      :unknown ->
        send_message(chat_id, "Unknown command. Use /help to see available commands.")
    end
  end

  defp handle_update(update) do
    Logger.info("Received non-text update: #{inspect(update)}")
  end

  defp parse_command(text) do
    case String.split(text, " ", parts: 3) do
      ["/start"] ->
        {:start}

      ["/help"] ->
        {:help}

      ["/list"] ->
        {:list}

      ["/add", url] ->
        {:add, url, nil}

      ["/add", url, name] ->
        {:add, url, name}

      ["/remove", id_str] ->
        case Integer.parse(id_str) do
          {id, ""} -> {:remove, id}
          _ -> :unknown
        end

      _ ->
        :unknown
    end
  end

  defp handle_add_link(chat_id, user, url, name) do
    case Links.add_link(user, url, name) do
      {:ok, link} ->
        send_message(chat_id, "✅ Added link: #{link.name || link.url}")

      {:error, changeset} when is_map(changeset) ->
        errors = Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)
        send_message(chat_id, "❌ Error: #{inspect(errors)}")

      {:error, message} ->
        send_message(chat_id, "❌ #{message}")
    end
  end

  defp handle_list_links(chat_id, user) do
    links = Links.list_user_links(user.id)

    if Enum.empty?(links) do
      send_message(chat_id, "You have no monitored links. Use /add to add one.")
    else
      message =
        links
        |> Enum.with_index(1)
        |> Enum.map(fn {link, _index} ->
          status_icon = if link.last_status == 200, do: "🟢", else: "🔴"

          "#{link.id}. #{status_icon} #{link.name || link.url}\n   Status: #{link.last_status || "Not checked"}"
        end)
        |> Enum.join("\n\n")

      send_message(chat_id, "Your monitored links:\n\n#{message}")
    end
  end

  defp handle_remove_link(chat_id, user, link_id) do
    case Links.remove_link(user, link_id) do
      {:ok, _} ->
        send_message(chat_id, "✅ Link removed successfully")

      {:error, message} ->
        send_message(chat_id, "❌ #{message}")
    end
  end

  defp send_message(chat_id, text) do
    Logger.info("Sending message to #{chat_id}: #{text}")

    case Telegex.send_message(chat_id, text) do
      {:ok, message} ->
        Logger.info("Message sent successfully: #{message.message_id}")
        :ok

      {:error, reason} ->
        Logger.error("Failed to send message: #{inspect(reason)}")
    end
  end
end

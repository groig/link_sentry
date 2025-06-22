defmodule LinkSentry.Monitor do
  alias LinkSentry.{Links, Notifications}
  require Logger

  def check_link(link) do
    start_time = System.monotonic_time(:millisecond)

    request = Finch.build(:head, link.url)

    case Finch.request(request, LinkSentryFinch) do
      {:ok, %Finch.Response{status: status_code}} ->
        response_time = System.monotonic_time(:millisecond) - start_time
        handle_successful_check(link, status_code, response_time)

      {:error, reason} ->
        response_time = System.monotonic_time(:millisecond) - start_time
        handle_failed_check(link, reason, response_time)
    end
  end

  defp handle_successful_check(link, status_code, response_time) do
    Links.update_link_status(link, status_code, response_time)
    Links.record_check(link.id, status_code, response_time)

   case {status_code, link.last_status} do
      {200, last_status} when last_status != 200 ->
        message = "🟢 #{link.name || link.url} is back up"
        Notifications.notify_user(link.user, message)
      {code, _} when code != 200 ->
        message = "🔴 #{link.name || link.url} is down"
        Notifications.notify_user(link.user, message)
      _ ->
        :ok
    end

    # Check for significant response time variation
    check_response_time_variation(link, response_time)
  end

  defp handle_failed_check(link, reason, response_time) do
    error_message = format_error(reason)
    Links.record_check(link.id, nil, response_time, error_message)

    message = "🔴 #{link.name || link.url} failed: #{error_message}"
    Notifications.notify_user(link.user, message)
  end

  defp check_response_time_variation(link, current_response_time) do
    recent_checks = Links.get_recent_checks(link.id, 5)

    if length(recent_checks) >= 3 do
      response_times = Enum.map(recent_checks, & &1.response_time)
      avg_response_time = Enum.sum(response_times) / length(response_times)

      # Alert if current response time is 2x slower than average
      if current_response_time > avg_response_time * 2 do
        message =
          "⚠️ #{link.name || link.url} is responding slowly (#{current_response_time}ms vs avg #{round(avg_response_time)}ms)"

        Notifications.notify_user(link.user, message)
      end
    end
  end

  defp format_error(reason) do
    case reason do
      %Mint.TransportError{reason: :timeout} -> "Request timeout"
      %Mint.TransportError{reason: :econnrefused} -> "Connection refused"
      %Mint.TransportError{reason: :nxdomain} -> "Domain not found"
      %Mint.HTTPError{reason: reason} -> "HTTP error: #{reason}"
      other -> "#{inspect(other)}"
    end
  end
end

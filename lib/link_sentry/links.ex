defmodule LinkSentry.Links do
  alias LinkSentry.{Repo, Link, Check}
  import Ecto.Query

  def add_link(user, url, name \\ nil) do
    user_links_count = get_user_links_count(user.id)

    if user_links_count >= 5 do
      {:error, "You can only monitor up to 5 links"}
    else
      %Link{}
      |> Link.changeset(%{
        url: url,
        name: name,
        user_id: user.id
      })
      |> Repo.insert()
    end
  end

  def remove_link(user, link_id) do
    case get_user_link(user.id, link_id) do
      nil ->
        {:error, "Link not found"}

      link ->
        Repo.delete_all(from(c in Check, where: c.link_id == ^link_id))
        Repo.delete(link)
    end
  end

  def list_user_links(user_id) do
    from(l in Link,
      where: l.user_id == ^user_id and l.is_active == true,
      order_by: [asc: l.inserted_at]
    )
    |> Repo.all()
  end

  def get_user_link(user_id, link_id) do
    Repo.get_by(Link, id: link_id, user_id: user_id, is_active: true)
  end

  def get_all_active_links do
    from(l in Link,
      where: l.is_active == true,
      preload: [:user]
    )
    |> Repo.all()
  end

  defp get_user_links_count(user_id) do
    from(l in Link,
      where: l.user_id == ^user_id and l.is_active == true,
      select: count(l.id)
    )
    |> Repo.one()
  end

  def update_link_status(link, status_code, response_time) do
    Link.changeset(link, %{
      last_status: status_code,
      last_response_time: response_time,
      last_checked_at: DateTime.utc_now()
    })
    |> Repo.update()
  end

  def record_check(link_id, status_code, response_time, error_message \\ nil) do
    # Insert the new check
    result =
      %Check{}
      |> Check.changeset(%{
        link_id: link_id,
        status_code: status_code,
        response_time: response_time,
        error_message: error_message,
        checked_at: DateTime.utc_now()
      })
      |> Repo.insert()

    cleanup_old_checks(link_id)

    result
  end

  defp cleanup_old_checks(link_id) do
    keep_ids =
      from(c in Check,
        where: c.link_id == ^link_id,
        order_by: [desc: c.checked_at],
        limit: 5,
        select: c.id
      )
      |> Repo.all()

    from(c in Check,
      where: c.link_id == ^link_id and c.id not in ^keep_ids
    )
    |> Repo.delete_all()
  end

  def get_recent_checks(link_id, limit \\ 5) do
    from(c in Check,
      where: c.link_id == ^link_id,
      order_by: [desc: c.checked_at],
      limit: ^limit
    )
    |> Repo.all()
  end
end

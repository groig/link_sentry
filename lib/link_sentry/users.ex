defmodule LinkSentry.Users do
  alias LinkSentry.{Repo, User}

  def find_or_create_user(telegram_user) do
    case Repo.get_by(User, telegram_id: telegram_user.id) do
      nil ->
        %User{}
        |> User.changeset(%{
          telegram_id: telegram_user.id,
          username: telegram_user.username,
        })
        |> Repo.insert()

      user ->
        {:ok, user}
    end
  end

  def get_user_by_telegram_id(telegram_id) do
    Repo.get_by(User, telegram_id: telegram_id)
  end
end

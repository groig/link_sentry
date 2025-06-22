defmodule LinkSentry.Repo.Migrations.CreateLinks do
  use Ecto.Migration

  def change do
    create table(:links) do
      add(:url, :string, null: false)
      add(:name, :string)
      add(:is_active, :boolean, default: true)
      add(:last_status, :integer)
      add(:last_response_time, :integer)
      add(:last_checked_at, :utc_datetime)
      add(:user_id, references(:users, on_delete: :delete_all), null: false)

      timestamps()
    end

    create(index(:links, [:user_id]))
    create(index(:links, [:is_active]))
  end
end

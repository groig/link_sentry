defmodule LinkSentry.Repo.Migrations.CreateChecks do
  use Ecto.Migration

  def change do
    create table(:checks) do
      add(:status_code, :integer)
      add(:response_time, :integer)
      add(:error_message, :string)
      add(:checked_at, :utc_datetime, null: false)
      add(:link_id, references(:links, on_delete: :delete_all), null: false)

      timestamps(updated_at: false)
    end

    create(index(:checks, [:link_id, :checked_at]))
  end
end

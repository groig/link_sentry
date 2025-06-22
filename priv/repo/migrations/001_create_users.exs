defmodule LinkSentry.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add(:telegram_id, :integer, null: false)
      add(:username, :string)
      add(:is_active, :boolean, default: true)

      timestamps()
    end

    create(unique_index(:users, [:telegram_id]))
  end
end

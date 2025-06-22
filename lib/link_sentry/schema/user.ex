defmodule LinkSentry.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field(:telegram_id, :integer)
    field(:username, :string)
    field(:is_active, :boolean, default: true)

    has_many(:links, LinkSentry.Link)

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:telegram_id, :username, :is_active])
    |> validate_required([:telegram_id])
    |> unique_constraint(:telegram_id)
  end
end

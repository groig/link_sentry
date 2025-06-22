defmodule LinkSentry.Link do
  use Ecto.Schema
  import Ecto.Changeset

  schema "links" do
    field(:url, :string)
    field(:name, :string)
    field(:is_active, :boolean, default: true)
    field(:last_status, :integer)
    field(:last_response_time, :integer)
    field(:last_checked_at, :utc_datetime)

    belongs_to(:user, LinkSentry.User)
    has_many(:checks, LinkSentry.Check)

    timestamps()
  end

  def changeset(link, attrs) do
    link
    |> cast(attrs, [
      :url,
      :name,
      :is_active,
      :last_status,
      :last_response_time,
      :last_checked_at,
      :user_id
    ])
    |> validate_required([:url, :user_id])
    |> validate_format(:url, ~r/^https?:\/\//)
    |> validate_length(:name, max: 100)
  end
end

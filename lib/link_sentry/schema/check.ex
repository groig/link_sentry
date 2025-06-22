defmodule LinkSentry.Check do
  use Ecto.Schema
  import Ecto.Changeset

  schema "checks" do
    field(:status_code, :integer)
    field(:response_time, :integer)
    field(:error_message, :string)
    field(:checked_at, :utc_datetime)

    belongs_to(:link, LinkSentry.Link)

    timestamps(updated_at: false)
  end

  def changeset(check, attrs) do
    check
    |> cast(attrs, [:status_code, :response_time, :error_message, :checked_at, :link_id])
    |> validate_required([:checked_at, :link_id])
  end
end

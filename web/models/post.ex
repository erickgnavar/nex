defmodule Nex.Post do
  use Nex.Web, :model

  schema "posts" do
    field :title, :string
    field :body, :string

    many_to_many :tags, Nex.Tag, join_through: "posts_tags"

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :body])
    |> put_assoc(:tags, Map.get(params, "tags", []))  # tags list is optional
    |> validate_required([:title, :body])
  end

  def latest(query) do
    query
    |> preload(:tags)
    |> order_by(desc: :inserted_at)
    |> limit(10)
  end
end

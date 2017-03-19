defmodule Nex.Post do
  use Nex.Web, :model

  schema "posts" do
    field :title, :string
    field :body, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :body])
    |> validate_required([:title, :body])
  end

  def latest(query) do
    query
    |> order_by(desc: :inserted_at)
    |> limit(10)
  end
end

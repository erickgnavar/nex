defmodule Nex.Tag do
  use Nex.Web, :model

  schema "tags" do
    field :name, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name])
    |> validate_required([:name])
  end

  def by_ids(query, ids) do
    query
    |> where([t], t.id in ^ids)
  end
end

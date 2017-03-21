defmodule Nex.Token do
  use Nex.Web, :model

  @expiration_days 3

  schema "tokens" do
    field :value, :string
    field :expire_at, Timex.Ecto.Date

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:value, :expire_at])
    |> unique_constraint(:value)
    |> validate_required([:value, :expire_at])
  end

  def new do
    struct = %__MODULE__{
      value: generate_value(),
      expire_at: Timex.today |> Timex.shift(days: @expiration_days)
    }
    Nex.Repo.insert!(struct)
  end

  def check(value) do
    case Nex.Repo.get_by(__MODULE__, value: value) do
      nil ->
        {:error, "Token not found"}
      token ->
        if expired?(token) do
          {:error, "Token expired"}
        else
          {:ok, token}
        end
    end
  end

  def generate_value do
    :crypto.strong_rand_bytes(32)
    |> Base.encode64
  end

  defp expired?(token) do
    Timex.before?(token.expire_at, Timex.today)
  end
end

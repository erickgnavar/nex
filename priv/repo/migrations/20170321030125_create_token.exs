defmodule Nex.Repo.Migrations.CreateToken do
  use Ecto.Migration

  def change do
    create table(:tokens) do
      add :value, :string
      add :expire_at, :date

      timestamps()
    end

    create unique_index(:tokens, [:value])

  end
end

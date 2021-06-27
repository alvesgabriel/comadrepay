defmodule Comadrepay.Repo.Migrations.CreateTransfers do
  use Ecto.Migration

  def change do
    create table(:transfers, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :reversaled, :boolean, default: false, null: false
      add :from_account_id, references(:accounts, on_delete: :nothing, type: :binary_id)
      add :to_account_id, references(:accounts, on_delete: :nothing, type: :binary_id)
      add :value, :decimal, precision: 10, scale: 2

      timestamps()
    end

    create index(:transfers, [:from_account_id])
    create index(:transfers, [:to_account_id])
  end
end

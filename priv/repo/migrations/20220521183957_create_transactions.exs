defmodule MaxBank.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :type, :string, null: false
      add :amount, :decimal, null: false
      add :from_account_id, references(:accounts, on_delete: :nothing, type: :binary_id)
      add :to_account_id, references(:accounts, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:transactions, [:from_account_id])
    create index(:transactions, [:to_account_id])

    create constraint(:transactions, :amount_must_be_positive, check: "amount > 0")
  end
end

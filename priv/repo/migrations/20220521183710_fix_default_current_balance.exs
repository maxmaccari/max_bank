defmodule MaxBank.Repo.Migrations.FixDefaultCurrentBalance do
  use Ecto.Migration

  def change do
    alter table(:accounts) do
      modify :current_balance, :decimal, null: false, default: fragment("0.0")
    end
  end
end

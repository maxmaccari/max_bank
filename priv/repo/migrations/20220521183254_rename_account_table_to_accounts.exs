defmodule MaxBank.Repo.Migrations.RenameAccountTableToAccounts do
  use Ecto.Migration

  def change do
    rename table("account"), to: table("accounts")
  end
end

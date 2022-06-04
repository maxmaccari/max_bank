defmodule MaxBank.Banking.Account do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias MaxBank.Banking.Account
  alias MaxBank.Users.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accounts" do
    field :current_balance, :decimal, default: Decimal.new("0.0")

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [])
    |> assoc_constraint(:user, name: "account_user_id_fkey")
  end

  def increment_balance(account_id, amount) do
    Account
    |> from()
    |> where([a], a.id == ^account_id)
    |> select([a], a.current_balance)
    |> update([a], inc: [current_balance: ^amount])
  end
end

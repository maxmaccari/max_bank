defmodule MaxBank.Banking.Account do
  use Ecto.Schema
  import Ecto.Changeset

  alias MaxBank.Users.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "account" do
    field :current_balance, :decimal, default: Decimal.new("0.0")

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [])
    |> assoc_constraint(:user)
  end
end

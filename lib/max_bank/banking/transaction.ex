defmodule MaxBank.Banking.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  alias Ecto.Changeset
  alias MaxBank.Banking.Account

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "transactions" do
    field :amount, :decimal
    field :type, Ecto.Enum, values: [:deposit, :withdraw, :transference]

    belongs_to :from_account, Account
    belongs_to :to_account, Account

    timestamps()
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:type, :amount, :to_account_id])
    |> validate_required([:type, :amount])
    |> validate_number(:amount, greater_than: 0)
    |> normalize_account_ids()
    |> validate_account_ids()
    |> assoc_constraint(:from_account)
    |> assoc_constraint(:to_account)
  end

  defp validate_account_ids(%Changeset{changes: %{type: :deposit}} = changeset) do
    validate_required(changeset, [:to_account_id])
  end

  defp validate_account_ids(%Changeset{changes: %{type: :withdraw}} = changeset) do
    validate_required(changeset, [:from_account_id])
  end

  defp validate_account_ids(%Changeset{changes: %{type: :transference}} = changeset) do
    validate_required(changeset, [:from_account_id, :to_account_id])
  end

  defp validate_account_ids(changeset), do: changeset

  defp normalize_account_ids(%Changeset{changes: %{type: :deposit}} = changeset) do
    put_change(changeset, :from_account_id, nil)
  end

  defp normalize_account_ids(%Changeset{changes: %{type: :withdraw}} = changeset) do
    put_change(changeset, :to_account_id, nil)
  end

  defp normalize_account_ids(changeset), do: changeset
end

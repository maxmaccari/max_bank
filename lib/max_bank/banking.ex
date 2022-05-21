defmodule MaxBank.Banking do
  @moduledoc """
  The Banking context.
  """

  import Ecto.Query, warn: false
  alias MaxBank.Repo

  alias MaxBank.Users.User
  alias MaxBank.Banking.Account

  @doc """
  Returns the list of account.

  ## Examples

      iex> list_account()
      [%Account{}, ...]

  """
  def list_account do
    Repo.all(Account)
  end

  @doc """
  Gets a single account.

  Raises `Ecto.NoResultsError` if the Account does not exist.

  ## Examples

      iex> get_account!(123)
      %Account{}

      iex> get_account!(456)
      ** (Ecto.NoResultsError)

  """
  def get_account!(id), do: Repo.get!(Account, id)

  @doc """
  Creates a account.

  ## Examples

      iex> create_account(%User{})
      {:ok, %Account{}}

      iex> create_account(%User{})
      {:error, %Ecto.Changeset{}}

  """
  def create_account(%User{id: user_id}) do
    %Account{user_id: user_id}
    |> Account.changeset(%{})
    |> Repo.insert()
  end

  def account_from_user(%User{id: user_id}) do
    Account
    |> from(where: [user_id: ^user_id])
    |> Repo.one()
  end

  alias MaxBank.Banking.Transaction
  alias Ecto.Multi

  def create_transaction(%Account{id: id}, params) do
    transaction = %Transaction{
      to_account_id: id,
      from_account_id: id
    }

    Multi.new()
    |> Multi.insert(:transaction, Transaction.changeset(transaction, params))
    |> Multi.update_all(
      :balance,
      fn %{transaction: transaction} -> increment_balance(transaction) end,
      []
    )
    |> Multi.run(
      :ensure_positive_balance,
      fn _repo, %{balance: {_, [balance]}, transaction: transaction} ->
        if Decimal.negative?(balance) do
          {:error, Transaction.insuficient_funds_changeset(transaction)}
        else
          {:ok, balance}
        end
      end
    )
    |> Repo.transaction()
    |> normalize_response()
  end

  defp increment_balance(%{type: :deposit} = transaction) do
    increment_balance(transaction.to_account_id, transaction.amount)
  end

  defp increment_balance(%{type: :withdraw} = transaction) do
    amount = Decimal.negate(transaction.amount)
    increment_balance(transaction.from_account_id, amount)
  end

  defp increment_balance(account_id, amount) do
    Account
    |> from()
    |> where([a], a.id == ^account_id)
    |> select([a], a.current_balance)
    |> update([a], inc: [current_balance: ^amount])
  end

  defp normalize_response(response) do
    case response do
      {:ok, %{transaction: transaction}} -> {:ok, transaction}
      {:error, :transaction, changeset, _} -> {:error, changeset}
      {:error, _, reason, _} -> {:error, reason}
    end
  end
end

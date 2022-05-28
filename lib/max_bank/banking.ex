defmodule MaxBank.Banking do
  @moduledoc """
  The Banking context.
  """

  import Ecto.Query, warn: false
  alias MaxBank.Repo

  alias MaxBank.Users.User
  alias MaxBank.Banking.Account

  @doc """
  Returns the list of accounts.

  ## Examples

      iex> list_accounts()
      [%Account{}, ...]

  """
  def list_accounts do
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

    transaction
    |> Transaction.changeset(params)
    |> do_create_transaction()
  end

  defp do_create_transaction(transaction_changeset) do
    Multi.new()
    |> Multi.insert(:transaction, transaction_changeset)
    |> Multi.run(
      :incremented_balance,
      fn repo, %{transaction: transaction} -> increment_balance(repo, transaction) end
    )
    |> Multi.run(
      :decremented_balance,
      fn repo, %{transaction: transaction} -> decrement_balance(repo, transaction) end
    )
    |> Multi.run(:ensure_positive_balance, &ensure_positive_balance/2)
    |> Repo.transaction()
    |> normalize_response()
  end

  defp increment_balance(_repo, %{to_account_id: nil}), do: {:ok, nil}

  defp increment_balance(repo, %{to_account_id: to_account_id, amount: amount}) do
    to_account_id
    |> Account.increment_balance(amount)
    |> repo.update_all([])
    |> then(fn results -> {:ok, results} end)
  end

  defp decrement_balance(_repo, %{from_account_id: nil}), do: {:ok, nil}

  defp decrement_balance(repo, %{from_account_id: from_account_id, amount: amount}) do
    amount = Decimal.negate(amount)

    from_account_id
    |> Account.increment_balance(amount)
    |> repo.update_all([])
    |> then(fn results -> {:ok, results} end)
  end

  defp normalize_response(response) do
    case response do
      {:ok, %{transaction: transaction}} -> {:ok, transaction}
      {:error, :transaction, changeset, _} -> {:error, changeset}
      {:error, _, reason, _} -> {:error, reason}
    end
  end

  defp ensure_positive_balance(_repo, %{decremented_balance: {_, [balance]}, transaction: transaction}) do
    if Decimal.negative?(balance) do
      {:error, Transaction.insuficient_funds_changeset(transaction)}
    else
      {:ok, balance}
    end
  end

  defp ensure_positive_balance(_repo, _result), do: {:ok, nil}
end

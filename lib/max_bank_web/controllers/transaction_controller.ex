defmodule MaxBankWeb.TransactionController do
  use MaxBankWeb, :controller

  alias MaxBank.Banking
  alias MaxBank.Banking.{Account, Transaction}
  alias MaxBank.Users.User
  alias MaxBankWeb.UserAuth

  action_fallback MaxBankWeb.FallbackController

  def action(conn, _) do
    with %User{} = user <- UserAuth.current_user(conn),
         %Account{} = account <- Banking.account_from_user(user) do
      args = [conn, conn.params, account]
      apply(__MODULE__, action_name(conn), args)
    end
  end

  def index(conn, params, account) do
    transactions = Banking.list_transactions(account, sanitize_filter_params(params))
    render(conn, "index.json", transactions: transactions)
  end

  defp sanitize_filter_params(params) do
    for {key, value} <- params,
        parsed = maybe_convert_date(value),
        key in ["from", "to"],
        parsed != nil,
        do: {String.to_atom(key), parsed}
  end

  defp maybe_convert_date(value) do
    case NaiveDateTime.from_iso8601(value) do
      {:ok, value} -> value
      {:error, _} -> nil
    end
  end

  def create(conn, %{"transaction" => transaction_params}, account) do
    with {:ok, %Transaction{} = transaction} <-
           Banking.create_transaction(account, transaction_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.transaction_path(conn, :show, transaction))
      |> render("show.json", transaction: transaction)
    end
  end

  def show(conn, %{"id" => id}, account) do
    transaction = Banking.get_transaction!(account, id)
    render(conn, "show.json", transaction: transaction)
  end
end

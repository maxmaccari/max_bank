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

  def index(conn, _params, account) do
    transactions = Banking.list_transactions(account)
    render(conn, "index.json", transactions: transactions)
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

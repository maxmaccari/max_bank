defmodule MaxBankWeb.TransactionController do
  use MaxBankWeb, :controller

  alias MaxBank.Banking
  alias MaxBank.Banking.{Account, Transaction}
  alias MaxBank.Users.User
  alias MaxBankWeb.UserAuth

  action_fallback MaxBankWeb.FallbackController

  def create(conn, %{"transaction" => transaction_params}) do
    with %User{} = user <- UserAuth.current_user(conn),
         %Account{} = account <- Banking.account_from_user(user),
         {:ok, %Transaction{} = transaction} <-
           Banking.create_transaction(account, transaction_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.transaction_path(conn, :show, transaction))
      |> render("show.json", transaction: transaction)
    end
  end
end

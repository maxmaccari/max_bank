defmodule MaxBankWeb.AccountController do
  use MaxBankWeb, :controller

  alias MaxBank.Banking
  alias MaxBank.Banking.Account
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

  def show(conn, _params, account) do
    render(conn, "show.json", account: account)
  end
end

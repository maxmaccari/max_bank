defmodule MaxBankWeb.AccountView do
  use MaxBankWeb, :view

  def render("show.json", %{account: account}) do
    %{data: render_one(account, MaxBankWeb.AccountView, "account.json")}
  end

  def render("account.json", %{account: account}) do
    %{
      id: account.id,
      balance: account.current_balance
    }
  end
end

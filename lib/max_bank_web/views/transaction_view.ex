defmodule MaxBankWeb.TransactionView do
  use MaxBankWeb, :view
  alias MaxBankWeb.TransactionView

  def render("index.json", %{transactions: transactions}) do
    %{data: render_many(transactions, TransactionView, "transaction.json")}
  end

  def render("show.json", %{transaction: transaction}) do
    %{data: render_one(transaction, TransactionView, "transaction.json")}
  end

  def render("transaction.json", %{transaction: transaction}) do
    %{
      id: transaction.id,
      amount: transaction.amount,
      type: transaction.type,
      from_account_id: transaction.from_account_id,
      to_account_id: transaction.to_account_id,
      inserted_at: transaction.inserted_at
    }
  end
end

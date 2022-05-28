defmodule MaxBank.Factory do
  @moduledoc false

  # with Ecto
  use ExMachina.Ecto, repo: MaxBank.Repo
  import Faker.Person.PtBr, only: [name: 0]

  alias MaxBank.Users.User
  alias MaxBank.Banking.{Account, Transaction}

  def user_factory do
    %User{
      name: name(),
      email: sequence(:email, &"email-#{&1}@example.com"),
      password_hash: ""
    }
  end

  def account_factory do
    user = insert(:user)

    %Account{
      user_id: user.id
    }
  end

  def transaction_factory do
    account = insert(:account)

    %Transaction{
      to_account_id: account.id,
      amount: 1..100 |> Enum.random() |> Decimal.new(),
      type: :deposit
    }
  end
end

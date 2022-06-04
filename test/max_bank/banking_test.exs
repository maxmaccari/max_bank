defmodule MaxBank.BankingTest do
  use MaxBank.DataCase

  alias MaxBank.Banking

  describe "account" do
    alias MaxBank.Banking.Account
    alias MaxBank.Users.User

    test "list_accounts/0 returns all account" do
      account = insert(:account)
      assert Banking.list_accounts() == [account]
    end

    test "get_account!/1 returns the account with given id" do
      account = insert(:account)
      assert Banking.get_account!(account.id) == account
    end

    test "create_account/1 with valid data creates a account" do
      user = insert(:user)

      assert {:ok, %Account{} = account} = Banking.create_account(user)
      assert account.current_balance == Decimal.new("0.0")
      assert account.user_id == user.id
    end

    test "create_account/1 with invalid data returns error changeset" do
      fake_user = %User{id: Ecto.UUID.generate()}
      assert {:error, %Ecto.Changeset{} = changeset} = Banking.create_account(fake_user)
      assert errors_on(changeset) == %{user: ["does not exist"]}
    end

    test "account_from_user/1 with valid user returns the account" do
      user = insert(:user)
      expected_account = insert(:account, user_id: user.id)

      assert %Account{} = actual = Banking.account_from_user(user)
      assert actual.id == expected_account.id
    end
  end

  describe "transactions" do
    alias MaxBank.Banking.{Account, Transaction}

    test "create_transaction/2 with valid deposit data creates a deposit transaction" do
      account = insert(:account)

      params = %{
        type: :deposit,
        amount: "100.0"
      }

      assert {:ok, %Transaction{} = transaction} = Banking.create_transaction(account, params)
      assert transaction.type == :deposit
      assert transaction.amount == Decimal.new("100.0")
      assert transaction.to_account_id == account.id
      assert transaction.from_account_id == nil
    end

    test "create_transaction/2 with to_account_id creates a deposit transaction to another account" do
      account = insert(:account)
      another_account = insert(:account)

      params = %{
        type: :deposit,
        amount: "100.0",
        to_account_id: another_account.id
      }

      assert {:ok, %Transaction{} = transaction} = Banking.create_transaction(account, params)
      assert transaction.to_account_id == another_account.id
    end

    test "create_transaction/2 with valid deposit data update the account current_balance" do
      account = insert(:account)

      params = %{
        type: :deposit,
        amount: "100.0"
      }

      Banking.create_transaction(account, params)
      account = Banking.get_account!(account.id)

      assert account.current_balance == Decimal.new("100.0")
    end

    test "create_transaction/2 with valid withdraw data creates a withdraw transaction" do
      account = insert(:account, current_balance: Decimal.new("200.0"))

      params = %{
        type: :withdraw,
        amount: "100.0"
      }

      assert {:ok, %Transaction{} = transaction} = Banking.create_transaction(account, params)
      assert transaction.type == :withdraw
      assert transaction.amount == Decimal.new("100.0")
      assert transaction.from_account_id == account.id
      assert transaction.to_account_id == nil
    end

    test "create_transaction/2 with valid withdraw data update the account current_balance" do
      account = insert(:account, current_balance: Decimal.new("200.0"))

      params = %{
        type: :withdraw,
        amount: "100.0"
      }

      Banking.create_transaction(account, params)
      account = Banking.get_account!(account.id)

      assert account.current_balance == Decimal.new("100.0")
    end

    test "create_transaction/2 with valid withdraw data doesn't allow to withdraw with insuficient funds" do
      account = insert(:account, current_balance: Decimal.new("50.0"))

      params = %{
        type: :withdraw,
        amount: "100.0"
      }

      assert {:error, %Ecto.Changeset{} = changeset} = Banking.create_transaction(account, params)

      assert %{amount: ["insuficient funds"]} = errors_on(changeset)
    end

    test "create_transaction/2 with valid transference data creates a transference transaction" do
      from_account = insert(:account, current_balance: Decimal.new("100.0"))
      to_account = insert(:account)

      params = %{
        type: :transference,
        amount: "100.0",
        to_account_id: to_account.id
      }

      assert {:ok, %Transaction{} = transaction} =
               Banking.create_transaction(from_account, params)

      assert transaction.type == :transference
      assert transaction.amount == Decimal.new("100.0")
      assert transaction.to_account_id == to_account.id
      assert transaction.from_account_id == from_account.id
    end

    test "create_transaction/2 with valid transference data update the accounts current_balance" do
      from_account = insert(:account, current_balance: Decimal.new("100.0"))
      to_account = insert(:account)

      params = %{
        type: :transference,
        amount: "100.0",
        to_account_id: to_account.id
      }

      Banking.create_transaction(from_account, params)

      from_account = Banking.get_account!(from_account.id)
      to_account = Banking.get_account!(to_account.id)

      assert from_account.current_balance == Decimal.new("0.0")
      assert to_account.current_balance == Decimal.new("100.0")
    end

    test "create_transaction/2 with valid transference data doesn't allow to transference with insuficient funds" do
      from_account = insert(:account, current_balance: Decimal.new("50.0"))
      to_account = insert(:account)

      params = %{
        type: :transference,
        amount: "100.0",
        to_account_id: to_account.id
      }

      assert {:error, %Ecto.Changeset{} = changeset} =
               Banking.create_transaction(from_account, params)

      assert %{amount: ["insuficient funds"]} = errors_on(changeset)
    end

    test "create_transaction/2 with invalid data doesn't create the transaction" do
      account = insert(:account)

      params = %{
        type: :non_supported,
        amount: "0.0"
      }

      assert {:error, %Ecto.Changeset{} = changeset} = Banking.create_transaction(account, params)

      assert %{
               amount: ["must be greater than 0"],
               type: ["is invalid"]
             } = errors_on(changeset)
    end

    test "create_transaction/2 with invalid to_account_id doesn't create the transaction" do
      account = insert(:account)

      params = %{
        type: :deposit,
        amount: "100.0",
        to_account_id: Ecto.UUID.generate()
      }

      assert {:error, %Ecto.Changeset{} = changeset} = Banking.create_transaction(account, params)

      assert %{
               to_account: ["does not exist"]
             } = errors_on(changeset)
    end

    test "list_transactions/1 returns the transactions list from account" do
      insert(:transaction)
      %{to_account_id: account_id, id: id} = insert(:transaction)
      account = Banking.get_account!(account_id)

      assert [%Transaction{id: ^id}] = Banking.list_transactions(account)
    end

    test "list_transactions/2 returns the transactions filtering by date" do
      account = insert(:account)

      %{id: first_id} =
        insert(:transaction,
          to_account_id: account.id,
          inserted_at: NaiveDateTime.new!(2022, 1, 1, 12, 0, 0)
        )

      %{id: middle_id} =
        insert(:transaction,
          to_account_id: account.id,
          inserted_at: NaiveDateTime.new!(2022, 1, 2, 12, 0, 0)
        )

      %{id: last_id} =
        insert(:transaction,
          to_account_id: account.id,
          inserted_at: NaiveDateTime.new!(2022, 1, 3, 12, 0, 0)
        )

      assert [%Transaction{id: ^first_id}] =
               Banking.list_transactions(account, to: NaiveDateTime.new!(2022, 1, 1, 13, 0, 0))

      assert [%Transaction{id: ^last_id}] =
               Banking.list_transactions(account, from: NaiveDateTime.new!(2022, 1, 3, 12, 0, 0))

      assert [%Transaction{id: ^middle_id}] =
               Banking.list_transactions(account,
                 from: NaiveDateTime.new!(2022, 1, 2, 0, 0, 0),
                 to: NaiveDateTime.new!(2022, 1, 2, 23, 59, 59)
               )
    end

    test "get_transaction!/2 returns the transaction from account" do
      %{to_account_id: account_id, id: id} = insert(:transaction)
      account = Banking.get_account!(account_id)

      assert %Transaction{id: ^id} = Banking.get_transaction!(account, id)
    end
  end
end

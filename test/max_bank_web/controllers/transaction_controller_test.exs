defmodule MaxBankWeb.TransactionControllerTest do
  use MaxBankWeb.ConnCase

  @invalid_attrs %{amount: nil, type: nil}

  setup :authenticated_user

  setup %{user: user} do
    account = insert(:account, user_id: user.id)

    {:ok, [account: account]}
  end

  describe "index" do
    test "lists all transactions from the given account", %{conn: conn, account: account} do
      %{id: id} = insert(:transaction, to_account_id: account.id)

      conn = get(conn, Routes.transaction_path(conn, :index))
      assert [%{"id" => ^id}] = json_response(conn, 200)["data"]
    end

    test "filter transactions by date", %{conn: conn, account: account} do
      insert(:transaction,
        to_account_id: account.id,
        inserted_at: NaiveDateTime.new!(2022, 1, 1, 12, 0, 0)
      )

      insert(:transaction,
        to_account_id: account.id,
        inserted_at: NaiveDateTime.new!(2022, 1, 3, 12, 0, 0)
      )

      %{id: id} =
        insert(:transaction,
          to_account_id: account.id,
          inserted_at: NaiveDateTime.new!(2022, 1, 2, 12, 0, 0)
        )

      conn =
        get(
          conn,
          Routes.transaction_path(conn, :index,
            from: "2022-01-02 11:00:00",
            to: "2022-01-02 13:00:00"
          )
        )

      assert [%{"id" => ^id}] = json_response(conn, 200)["data"]
    end
  end

  describe "create transaction" do
    test "renders transaction when data is valid", %{conn: conn, account: account} do
      %{id: account_id} = account

      valid_attrs = %{
        type: "deposit",
        amount: "100.00"
      }

      conn = post(conn, Routes.transaction_path(conn, :create), transaction: valid_attrs)

      assert %{
               "id" => id,
               "inserted_at" => inserted_at
             } = json_response(conn, 201)["data"]

      conn = get(conn, Routes.transaction_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "amount" => "100.00",
               "type" => "deposit",
               "to_account_id" => ^account_id,
               "inserted_at" => ^inserted_at
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.transaction_path(conn, :create), transaction: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end
end

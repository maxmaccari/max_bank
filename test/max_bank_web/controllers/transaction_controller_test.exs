defmodule MaxBankWeb.TransactionControllerTest do
  use MaxBankWeb.ConnCase

  alias MaxBankWeb.UserAuth

  @invalid_attrs %{amount: nil, type: nil}

  setup %{conn: conn} do
    user = insert(:user)
    account = insert(:account, user_id: user.id)

    {:ok, token} = UserAuth.encode_and_sign(user)

    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", "Bearer #{token}")

    {:ok,
     [
       conn: put_req_header(conn, "accept", "application/json"),
       account: account,
       user: user
     ]}
  end

  describe "index" do
    test "lists all transactions from the given account", %{conn: conn, account: account} do
      %{id: id} = insert(:transaction, to_account_id: account.id)

      conn = get(conn, Routes.transaction_path(conn, :index))
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
               "id" => id
             } = json_response(conn, 201)["data"]

      conn = get(conn, Routes.transaction_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "amount" => "100.00",
               "type" => "deposit",
               "to_account_id" => ^account_id
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.transaction_path(conn, :create), transaction: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end
end

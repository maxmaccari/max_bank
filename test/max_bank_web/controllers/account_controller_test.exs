defmodule MaxBankWeb.AccountControllerTest do
  use MaxBankWeb.ConnCase

  alias MaxBankWeb.UserAuth

  setup %{conn: conn} do
    user = insert(:user)

    {:ok, token} = UserAuth.encode_and_sign(user)

    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", "Bearer #{token}")

    {:ok,
     [
       conn: put_req_header(conn, "accept", "application/json"),
       user: user
     ]}
  end

  test "show account", %{conn: conn, user: user} do
    %{id: id} = insert(:account, user_id: user.id, current_balance: Decimal.new("100.00"))

    conn = get(conn, Routes.account_path(conn, :show))

    assert %{
             "id" => ^id,
             "balance" => "100.00"
           } = json_response(conn, 200)["data"]
  end
end

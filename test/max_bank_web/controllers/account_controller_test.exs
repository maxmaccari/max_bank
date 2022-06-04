defmodule MaxBankWeb.AccountControllerTest do
  use MaxBankWeb.ConnCase

  setup :authenticated_user

  test "show account", %{conn: conn, user: user} do
    %{id: id} = insert(:account, user_id: user.id, current_balance: Decimal.new("100.00"))

    conn = get(conn, Routes.account_path(conn, :show))

    assert %{
             "id" => ^id,
             "balance" => "100.00"
           } = json_response(conn, 200)["data"]
  end
end

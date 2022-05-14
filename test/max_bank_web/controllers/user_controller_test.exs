defmodule MaxBankWeb.UserControllerTest do
  use MaxBankWeb.ConnCase

  @invalid_attrs %{email: nil, name: nil, password: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      user_params = valid_user_params()

      conn = post(conn, Routes.user_path(conn, :create), user: user_params)
      assert %{"id" => _id, "email" => email, "name" => name} = json_response(conn, 201)["data"]
      assert email == user_params.email
      assert name == user_params.name
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end

    alias MaxBank.{Banking, Users}
    alias MaxBank.Banking.Account

    test "create one banking account when the user is created", %{conn: conn} do
      user_params = valid_user_params()

      conn = post(conn, Routes.user_path(conn, :create), user: user_params)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      assert %Account{user_id: ^id} = id |> Users.get_user!() |> Banking.account_from_user()
    end
  end
end

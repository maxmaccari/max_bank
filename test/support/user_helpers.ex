defmodule MaxBank.UserHelpers do
  import MaxBank.Factory
  import Plug.Conn

  alias MaxBankWeb.UserAuth

  def valid_user_params(password \\ "123456") do
    :user
    |> params_for(password: password)
    |> Map.put(:password_confirmation, password)
  end

  def authenticated_user(%{conn: conn}) do
    user = insert(:user)

    {:ok, token} = UserAuth.encode_and_sign(user)

    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", "Bearer #{token}")

    {:ok,
     [
       token: token,
       conn: conn,
       user: user
     ]}
  end
end

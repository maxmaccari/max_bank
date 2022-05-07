defmodule MaxBankWeb.SessionController do
  use MaxBankWeb, :controller

  alias MaxBank.Users
  alias MaxBank.Users.User
  alias MaxBankWeb.UserAuth

  action_fallback(MaxBankWeb.FallbackController)

  def create(conn, %{"credentials" => %{"email" => email, "password" => password}}) do
    with {:ok, %User{} = user} <- Users.authenticate_user(email, password),
         {:ok, token} <- UserAuth.encode_and_sign(user) do
      conn
      |> put_status(:created)
      |> render("show.json", session: %{user: user, token: token})
    else
      {:error, :unauthorized} ->
        conn
        |> put_status(:unauthorized)
        |> render("invalid_credentials.json")

      error ->
        error
    end
  end

  def delete(conn, _params) do
    :ok = UserAuth.revoke_current_token(conn)

    send_resp(conn, :no_content, "")
  end
end

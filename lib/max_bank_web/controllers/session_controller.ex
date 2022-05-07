defmodule MaxBankWeb.SessionController do
  use MaxBankWeb, :controller

  alias MaxBank.UserAuth
  alias MaxBank.UserAuth.User
  alias MaxBank.UserAuth.Guardian

  action_fallback MaxBankWeb.FallbackController

  def create(conn, %{"credentials" => %{"email" => email, "password" => password}}) do
    with {:ok, %User{} = user} <- UserAuth.authenticate_user(email, password),
         {:ok, token, _claim} = encode_and_sign(user) do
      conn
      |> put_status(:created)
      |> render("show.json", session: %{user: user, token: token})
    end
  end

  defp encode_and_sign(user) do
    Guardian.encode_and_sign(user, %{}, token_type: "access", ttl: {15, :minutes})
  end
end
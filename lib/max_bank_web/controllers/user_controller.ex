defmodule MaxBankWeb.UserController do
  use MaxBankWeb, :controller

  alias MaxBank.Users
  alias MaxBank.Users.User

  action_fallback(MaxBankWeb.FallbackController)

  def create(conn, %{"user" => user_params}) do
    case MaxBank.register_user_and_account(user_params) do
      {:ok, %{user: %User{} = user}} ->
        conn
        |> put_status(:created)
        |> render("show.json", user: user)

      {:error, _, reason, _} ->
        {:error, reason}
    end
  end
end

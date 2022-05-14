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

  def show(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    render(conn, "show.json", user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Users.get_user!(id)

    with {:ok, %User{} = user} <- Users.update_user(user, user_params) do
      render(conn, "show.json", user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Users.get_user!(id)

    with {:ok, %User{}} <- Users.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end

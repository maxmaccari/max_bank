defmodule MaxBankWeb.UserController do
  use MaxBankWeb, :controller

  alias MaxBank.UserAuth
  alias MaxBank.UserAuth.User

  action_fallback MaxBankWeb.FallbackController

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- UserAuth.register_user(user_params) do
      conn
      |> put_status(:created)
      |> render("show.json", user: user)
    end
  end

  def show(conn, %{"id" => id}) do
    user = UserAuth.get_user!(id)
    render(conn, "show.json", user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = UserAuth.get_user!(id)

    with {:ok, %User{} = user} <- UserAuth.update_user(user, user_params) do
      render(conn, "show.json", user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = UserAuth.get_user!(id)

    with {:ok, %User{}} <- UserAuth.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end

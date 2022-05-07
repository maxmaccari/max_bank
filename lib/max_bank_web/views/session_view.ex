defmodule MaxBankWeb.SessionView do
  use MaxBankWeb, :view
  alias MaxBankWeb.SessionView

  def render("show.json", %{session: session}) do
    %{data: render_one(session, SessionView, "session.json")}
  end

  def render("session.json", %{session: %{user: user, token: token}}) do
    %{
      user: %{
        id: user.id,
        email: user.email,
        name: user.name
      },
      token: token
    }
  end

  def render("invalid_credentials.json", _) do
    %{
      error: %{
        message: "invalid credentials"
      }
    }
  end
end

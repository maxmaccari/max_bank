defmodule MaxBankWeb.PageController do
  use MaxBankWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end

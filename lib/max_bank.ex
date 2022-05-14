defmodule MaxBank do
  @moduledoc """
  MaxBank keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias MaxBank.Repo
  alias Ecto.Multi

  alias MaxBank.Banking
  alias MaxBank.Users

  def register_user_and_account(user_params) do
    Multi.new()
    |> Multi.run(:user, fn _, _ -> Users.register_user(user_params) end)
    |> Multi.run(:account, fn _, %{user: user} -> Banking.create_account(user) end)
    |> Repo.transaction()
  end
end

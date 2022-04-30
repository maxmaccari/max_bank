defmodule MaxBank.UserAuthFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MaxBank.UserAuth` context.
  """

  alias Faker.Internet
  alias Faker.Person.PtBr, as: Person

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: Internet.email(),
        name: Person.name(),
        password_hash: ""
      })
      |> MaxBank.UserAuth.create_user()

    user
  end
end

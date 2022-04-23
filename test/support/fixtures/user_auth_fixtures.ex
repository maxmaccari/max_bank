defmodule MaxBank.UserAuthFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MaxBank.UserAuth` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: Faker.Internet.email(),
        name: Faker.Person.PtBr.name(),
        password_hash: ""
      })
      |> MaxBank.UserAuth.create_user()

    user
  end
end

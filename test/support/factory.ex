defmodule MaxBank.Factory do
  # with Ecto
  use ExMachina.Ecto, repo: MaxBank.Repo
  import Faker.Person.PtBr, only: [name: 0]

  alias MaxBank.UserAuth.User

  def user_factory do
    %User{
      name: name(),
      email: sequence(:email, &"email-#{&1}@example.com"),
      password_hash: ""
    }
  end
end

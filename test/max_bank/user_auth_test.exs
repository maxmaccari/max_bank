defmodule MaxBank.UserAuthTest do
  use MaxBank.DataCase

  alias MaxBank.UserAuth

  describe "users" do
    alias MaxBank.UserAuth.User

    import MaxBank.Factory

    @invalid_attrs %{email: nil, name: nil, password_hash: nil}

    test "get_user!/1 returns the user with given id" do
      user = insert(:user)
      assert UserAuth.get_user!(user.id) == user
    end

    test "register_user/1 with valid data creates a user" do
      valid_attrs = %{
        email: "john@example.com",
        name: "John Doe",
        password: "123456",
        password_confirmation: "123456"
      }

      assert {:ok, %User{} = user} = UserAuth.register_user(valid_attrs)
      assert user.email == "john@example.com"
      assert user.name == "John Doe"
      assert Pbkdf2.verify_pass("123456", user.password_hash)
    end

    test "register_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = UserAuth.register_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = insert(:user)

      update_attrs = %{
        name: "John"
      }

      assert {:ok, %User{} = user} = UserAuth.update_user(user, update_attrs)
      assert user.name == "John"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = insert(:user)
      assert {:error, %Ecto.Changeset{}} = UserAuth.update_user(user, @invalid_attrs)
      assert user == UserAuth.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = insert(:user)
      assert {:ok, %User{}} = UserAuth.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> UserAuth.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = insert(:user)
      assert %Ecto.Changeset{} = UserAuth.change_user(user)
    end

    test "authenticate_user/2 returns the user with the right credentials" do
      {:ok, user} = params_for(:user, password: "123456") |> UserAuth.register_user()

      assert {:ok, %User{} = authenticated_user} =
               UserAuth.authenticate_user(user.email, "123456")

      assert user.id == authenticated_user.id
    end

    test "authenticate_user/2 returns the error with the wrong credentials" do
      {:ok, user} = params_for(:user, password: "123456") |> UserAuth.register_user()

      assert {:error, :unauthorized} = UserAuth.authenticate_user(user.email, "123")
      assert {:error, :unauthorized} = UserAuth.authenticate_user("some_email@example.com", "123")
    end
  end
end

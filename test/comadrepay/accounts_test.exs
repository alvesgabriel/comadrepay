defmodule Comadrepay.AccountsTest do
  use Comadrepay.DataCase

  alias Comadrepay.Accounts

  import Comadrepay.AccountsFixtures

  describe "users" do
    alias Comadrepay.Accounts.User

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      user_attrs = user_valid_attrs()
      assert {:ok, %User{} = new_user} = Accounts.create_user(user_attrs)
      assert new_user.cpf == user_attrs.cpf
      assert new_user.email == user_attrs.email
      assert new_user.first_name == user_attrs.first_name
      assert new_user.last_name == user_attrs.last_name
      assert new_user.password == user_attrs.password
      assert new_user.password_confirmation == user_attrs.password_confirmation
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(user_invalid_attrs())
    end

    test "create_user/1 with invalid cpf returns error invalid verifier" do
      {:error, user} = Accounts.create_user(%{user_valid_attrs() | cpf: "123.456.789-00"})
      assert user.errors == [cpf: {"is invalid", [reason: :invalid_verifier]}]
    end

    test "create_user/1 with invalid cpf returns error invalid format" do
      {:error, user} = Accounts.create_user(%{user_valid_attrs() | cpf: "yyy.yyy.yyy-xx"})
      assert user.errors == [cpf: {"is invalid", [reason: :invalid_format]}]
    end

    test "create_user/1 with invalid email returns error invalid format" do
      {:error, user} = Accounts.create_user(%{user_valid_attrs() | email: "email.com"})
      assert user.errors == [email: {"email format invalid", [validation: :format]}]
    end

    test "create_user/1 with invalid password returns error invalid min length" do
      password = "1234"

      {:error, user} =
        Accounts.create_user(%{
          user_valid_attrs()
          | password: password,
            password_confirmation: password
        })

      assert user.errors == [
               password:
                 {"password length between 8 and 128",
                  [{:count, 8}, {:validation, :length}, {:kind, :min}, {:type, :string}]}
             ]
    end

    test "create_user/1 with invalid password returns error invalid max length" do
      password = String.duplicate("1", 129)

      {:error, user} =
        Accounts.create_user(%{
          user_valid_attrs()
          | password: password,
            password_confirmation: password
        })

      assert user.errors == [
               password:
                 {"password length between 8 and 128",
                  [{:count, 128}, {:validation, :length}, {:kind, :max}, {:type, :string}]}
             ]
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      user_attrs = user_update_attrs()
      assert {:ok, %User{} = user_updated} = Accounts.update_user(user, user_attrs)
      assert user_updated.cpf == user_attrs.cpf
      assert user_updated.email == user_attrs.email
      assert user_updated.first_name == user_attrs.first_name
      assert user_updated.last_name == user_attrs.last_name
      assert user_updated.password == user_attrs.password
      assert user_updated.password_confirmation == user_attrs.password_confirmation
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, user_invalid_attrs())
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end
end

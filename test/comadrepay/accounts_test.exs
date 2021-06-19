defmodule Comadrepay.AccountsTest do
  use Comadrepay.DataCase

  alias Comadrepay.Accounts

  describe "users" do
    alias Comadrepay.Accounts.User

    @valid_attrs %{
      cpf: "544.274.033-01",
      email: "user@email.com",
      first_name: "some first_name",
      last_name: "some last_name",
      password: "some password_hash",
      password_confirmation: "some password_hash"
    }
    @update_attrs %{
      cpf: "895.377.376-83",
      email: "user123@email.com",
      first_name: "some updated first_name",
      last_name: "some updated last_name",
      password: "some updated password_hash",
      password_confirmation: "some updated password_hash"
    }
    @invalid_attrs %{
      cpf: nil,
      email: nil,
      first_name: nil,
      last_name: nil,
      password: nil,
      password_confirmation: nil
    }

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      %{user | password: nil, password_confirmation: nil}
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.cpf == "544.274.033-01"
      assert user.email == "user@email.com"
      assert user.first_name == "some first_name"
      assert user.last_name == "some last_name"
      assert user.password == "some password_hash"
      assert user.password_confirmation == "some password_hash"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "create_user/1 with invalid cpf returns error invalid verifier" do
      {:error, user} = Accounts.create_user(%{@valid_attrs | cpf: "123.456.789-00"})
      assert user.errors == [cpf: {"is invalid", [reason: :invalid_verifier]}]
    end

    test "create_user/1 with invalid cpf returns error invalid format" do
      {:error, user} = Accounts.create_user(%{@valid_attrs | cpf: "yyy.yyy.yyy-xx"})
      assert user.errors == [cpf: {"is invalid", [reason: :invalid_format]}]
    end

    test "create_user/1 with invalid email returns error invalid format" do
      {:error, user} = Accounts.create_user(%{@valid_attrs | email: "email.com"})
      assert user.errors == [email: {"email format invalid", [validation: :format]}]
    end

    test "create_user/1 with invalid password returns error invalid min length" do
      password = "1234"

      {:error, user} =
        Accounts.create_user(%{@valid_attrs | password: password, password_confirmation: password})

      assert user.errors == [
               password:
                 {"password length between 8 and 128",
                  [{:count, 8}, {:validation, :length}, {:kind, :min}, {:type, :string}]}
             ]
    end

    test "create_user/1 with invalid password returns error invalid max length" do
      password = String.duplicate("1", 129)

      {:error, user} =
        Accounts.create_user(%{@valid_attrs | password: password, password_confirmation: password})

      assert user.errors == [
               password:
                 {"password length between 8 and 128",
                  [{:count, 128}, {:validation, :length}, {:kind, :max}, {:type, :string}]}
             ]
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Accounts.update_user(user, @update_attrs)
      assert user.cpf == "895.377.376-83"
      assert user.email == "user123@email.com"
      assert user.first_name == "some updated first_name"
      assert user.last_name == "some updated last_name"
      assert user.password == "some updated password_hash"
      assert user.password_confirmation == "some updated password_hash"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
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

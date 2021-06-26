defmodule Comadrepay.AccountsFixtures do
  alias Comadrepay.Accounts

  def unique_email, do: "user#{System.unique_integer([:positive])}@email.com"
  def unique_cpf, do: CPF.generate() |> CPF.format()

  def user_valid_attrs() do
    %{
      cpf: unique_cpf(),
      email: unique_email(),
      first_name: "some first_name",
      last_name: "some last_name",
      password: "some password_hash",
      password_confirmation: "some password_hash"
    }
  end

  def user_update_attrs do
    %{
      cpf: unique_cpf(),
      email: unique_email(),
      first_name: "some updated first_name",
      last_name: "some updated last_name",
      password: "some updated password_hash",
      password_confirmation: "some updated password_hash"
    }
  end

  def user_invalid_attrs do
    %{
      cpf: nil,
      email: nil,
      first_name: nil,
      last_name: nil,
      password: nil,
      password_confirmation: nil
    }
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(user_valid_attrs())
      |> Accounts.create_user()

    %Accounts.User{user | password: nil, password_confirmation: nil}
  end
end

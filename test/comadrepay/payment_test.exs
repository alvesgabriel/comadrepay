defmodule Comadrepay.PaymentTest do
  use Comadrepay.DataCase

  alias Comadrepay.Payment

  describe "accounts" do
    alias Comadrepay.Payment.Account

    @valid_attrs %{balance: "120.50"}
    @update_attrs %{balance: "456.7"}
    @invalid_attrs %{balance: nil}

    def account_fixture(attrs \\ %{}) do
      {:ok, account} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Payment.create_account()

      account
    end

    test "list_accounts/0 returns all accounts" do
      account = account_fixture()
      assert Payment.list_accounts() == [account]
    end

    test "get_account!/1 returns the account with given id" do
      account = account_fixture()
      assert Payment.get_account!(account.id) == account
    end

    test "create_account/1 with valid data creates a account" do
      assert {:ok, %Account{} = account} = Payment.create_account(@valid_attrs)
      assert account.balance == Decimal.new("120.50")
    end

    test "create_account/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Payment.create_account(@invalid_attrs)
    end

    test "update_account/2 with valid data updates the account" do
      account = account_fixture()
      assert {:ok, %Account{} = account} = Payment.update_account(account, @update_attrs)
      assert account.balance == Decimal.new("456.7")
    end

    test "update_account/2 with invalid data returns error changeset" do
      account = account_fixture()
      assert {:error, %Ecto.Changeset{}} = Payment.update_account(account, @invalid_attrs)
      assert account == Payment.get_account!(account.id)
    end

    test "delete_account/1 deletes the account" do
      account = account_fixture()
      assert {:ok, %Account{}} = Payment.delete_account(account)
      assert_raise Ecto.NoResultsError, fn -> Payment.get_account!(account.id) end
    end

    test "change_account/1 returns a account changeset" do
      account = account_fixture()
      assert %Ecto.Changeset{} = Payment.change_account(account)
    end
  end
end

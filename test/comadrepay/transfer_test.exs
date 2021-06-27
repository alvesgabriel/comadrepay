defmodule Comadrepay.TransferTest do
  use Comadrepay.DataCase

  import Comadrepay.TransfersFixtures

  alias Comadrepay.Payment

  describe "accounts" do
    alias Comadrepay.Payment.Transfer

    test "create_transfer/1 with valid data creates a transfer" do
      transfer_attrs = transfer_valid()
      assert {:ok, %Transfer{} = transfer} = Payment.create_transfer(transfer_attrs)
      assert transfer.value == transfer_attrs.value
      assert transfer.reversaled == false
    end

    test "update_transfer/2 with valid data updates the transfer" do
      transfer_attrs = transfer_fixture()
      transfer_update = %{reversaled: true}

      assert {:ok, %Transfer{} = transfer} =
               Payment.update_transfer(transfer_attrs, transfer_update)

      assert transfer.reversaled == true
    end

    test "transfer/1 with valid data returns transfer" do
      %{
        from_account_id: from_account_id,
        to_account_id: to_account_id,
        value: value
      } = transfer_valid()

      assert {:ok, %Transfer{} = transfer} =
               Payment.transfer(from_account_id, to_account_id, value)

      assert from_account_id == transfer.from_account_id
      assert to_account_id == transfer.to_account_id

      from_account = Payment.get_account!(transfer.from_account_id)
      to_account = Payment.get_account!(transfer.to_account_id)

      assert from_account.balance == Decimal.sub(Decimal.new("1000"), value)
      assert to_account.balance == Decimal.add(Decimal.new("1000"), value)
    end

    test "transfer/1 with invalid data returns error transfer" do
      value = 2000

      %{
        from_account_id: from_account_id,
        to_account_id: to_account_id
      } = transfer_valid()

      assert {:error, %Ecto.Changeset{} = changeset} =
               Payment.transfer(from_account_id, to_account_id, value)

      assert changeset.errors == [
               {:balance,
                {"balance minimum is zero",
                 [validation: :number, kind: :greater_than, number: Decimal.new("0")]}}
             ]
    end
  end
end

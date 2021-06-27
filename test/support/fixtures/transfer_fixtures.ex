defmodule Comadrepay.TransfersFixtures do
  import Comadrepay.AccountsFixtures

  alias Comadrepay.Payment

  def random_value do
    (:rand.uniform() * 1000)
    |> Decimal.from_float()
    |> Decimal.round(2)
  end

  def transfer_valid do
    %{
      from_account_id: user_fixture().account.id,
      to_account_id: user_fixture().account.id,
      value: random_value()
    }
  end

  def transfer_fixture(attrs \\ %{}) do
    {:ok, transfer} =
      attrs
      |> Enum.into(transfer_valid())
      |> Payment.create_transfer()

    transfer
  end
end

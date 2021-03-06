defmodule Comadrepay.Payment.Account do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accounts" do
    field :balance, :decimal, default: 0

    belongs_to :user, Comadrepay.Accounts.User

    has_many :from_account, Comadrepay.Payment.Transfer, foreign_key: :from_account_id
    has_many :to_account, Comadrepay.Payment.Transfer, foreign_key: :to_account_id

    timestamps()
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:balance])
    |> validate_required([:balance])
    |> validate_number(
      :balance,
      greater_than: Decimal.new("0"),
      message: "balance minimum is zero"
    )
  end
end

defmodule Comadrepay.Payment.Transfer do
  use Ecto.Schema
  import Ecto.Changeset

  alias Comadrepay.Payment.Account

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "transfers" do
    field :reversaled, :boolean, default: false
    field :value, :decimal

    belongs_to :from_account, Account
    belongs_to :to_account, Account

    timestamps()
  end

  @doc false
  def changeset(transfer, attrs) do
    transfer
    |> cast(attrs, [:from_account_id, :to_account_id, :reversaled, :value])
    |> validate_required([:reversaled, :value])
  end
end

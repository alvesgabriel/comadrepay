defmodule Comadrepay.Payment do
  @moduledoc """
  The Payment context.
  """

  import Ecto.Query, warn: false
  alias Comadrepay.Repo

  alias Comadrepay.Payment.Account
  alias Comadrepay.Payment.Transfer

  @doc """
  Returns the list of accounts.

  ## Examples

      iex> list_accounts()
      [%Account{}, ...]

  """
  def list_accounts do
    Repo.all(Account)
  end

  @doc """
  Gets a single account.

  Raises `Ecto.NoResultsError` if the Account does not exist.

  ## Examples

      iex> get_account!(123)
      %Account{}

      iex> get_account!(456)
      ** (Ecto.NoResultsError)

  """
  def get_account!(id), do: Repo.get!(Account, id)

  @doc """
  Creates a account.

  ## Examples

      iex> create_account(%{field: value})
      {:ok, %Account{}}

      iex> create_account(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_account(attrs \\ %{}) do
    %Account{}
    |> Account.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a account.

  ## Examples

      iex> update_account(account, %{field: new_value})
      {:ok, %Account{}}

      iex> update_account(account, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_account(%Account{} = account, attrs) do
    account
    |> Account.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a account.

  ## Examples

      iex> delete_account(account)
      {:ok, %Account{}}

      iex> delete_account(account)
      {:error, %Ecto.Changeset{}}

  """
  def delete_account(%Account{} = account) do
    Repo.delete(account)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking account changes.

  ## Examples

      iex> change_account(account)
      %Ecto.Changeset{data: %Account{}}

  """
  def change_account(%Account{} = account, attrs \\ %{}) do
    Account.changeset(account, attrs)
  end

  def get_transfer!(account_id, id) do
    Repo.get_by!(Transfer, from_account_id: account_id, id: id)
  end

  def get_transfer!(id) do
    Repo.get!(Transfer, id)
  end

  def insert_transfer(attrs \\ %{}) do
    %Transfer{}
    |> Transfer.changeset(attrs)
  end

  def create_transfer(attrs \\ %{}) do
    insert_transfer(attrs)
    |> Repo.insert()
  end

  def change_transfer(%Transfer{} = transfer, attrs \\ %{}) do
    Transfer.changeset(transfer, attrs)
  end

  def update_transfer(%Transfer{} = transfer, attrs) do
    transfer
    |> Transfer.changeset(attrs)
    |> Repo.update()
  end

  defp build_transfer(transaction, from_account_id, to_account_id, value) do
    from_account = get_account!(from_account_id)
    to_account = get_account!(to_account_id)

    transaction
    |> Ecto.Multi.update(
      :from_account,
      fn _ ->
        debit = %{
          balance: Decimal.sub(from_account.balance, value)
        }

        change_account(from_account, debit)
      end
    )
    |> Ecto.Multi.update(
      :to_account,
      fn _ ->
        credit = %{
          balance: Decimal.add(to_account.balance, value)
        }

        change_account(to_account, credit)
      end
    )
    |> Comadrepay.Repo.transaction()
  end

  def transfer(from_account_id, to_account_id, value) do
    attrs = %{
      from_account_id: from_account_id,
      to_account_id: to_account_id,
      value: value
    }

    transaction =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(
        :transfer,
        insert_transfer(attrs)
      )
      |> build_transfer(
        from_account_id,
        to_account_id,
        value
      )

    case transaction do
      {:ok, result} -> {:ok, result.transfer}
      {:error, _, changeset, _} -> {:error, changeset}
    end
  end

  def reversal(id) do
    with %Transfer{} = transfered <- get_transfer!(id) do
      if transfered.reversaled do
        {:error, :already_reversaled}
      else
        transaction =
          Ecto.Multi.new()
          |> Ecto.Multi.update(
            :transfer,
            fn _ ->
              change_transfer(transfered, %{reversaled: true})
            end
          )
          |> build_transfer(
            transfered.to_account_id,
            transfered.from_account_id,
            transfered.value
          )

        case transaction do
          {:ok, result} -> {:ok, result.transfer}
          {:error, _, changeset, _} -> {:error, changeset}
        end
      end
    end
  end

  def statemet(date_begin, date_end, account_id) do
    {:ok, date_begin} = NaiveDateTime.from_iso8601(date_begin)
    {:ok, date_end} = NaiveDateTime.from_iso8601(date_end)

    query =
      from t in "transfers",
        where:
          (type(t.to_account_id, :string) >= ^account_id or
             type(t.from_account_id, :string) >= ^account_id) and
            t.inserted_at >= ^date_begin and
            t.inserted_at <= ^date_end,
        select: %Transfer{
          id: type(t.id, :string),
          from_account_id: type(t.from_account_id, :string),
          to_account_id: type(t.to_account_id, :string),
          value: t.value,
          reversaled: t.reversaled,
          inserted_at: t.inserted_at,
          updated_at: t.updated_at
        }

    Repo.all(query)
  end
end

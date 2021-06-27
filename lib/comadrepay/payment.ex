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

  def update_transfer(%Transfer{} = transfer, attrs) do
    transfer
    |> Transfer.changeset(attrs)
    |> Repo.update()
  end

  def transfer(from_account_id, to_account_id, value) do
    from_account = get_account!(from_account_id)
    to_account = get_account!(to_account_id)

    attrs = %{
      from_account_id: from_account.id,
      to_account_id: to_account.id,
      value: value
    }

    transaction =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(
        :transfer,
        insert_transfer(attrs),
        returning: true
      )
      |> Ecto.Multi.update(
        :from_account,
        fn %{transfer: _transfer} ->
          debit = %{
            balance: Decimal.sub(from_account.balance, attrs.value)
          }

          change_account(from_account, debit)
        end
      )
      |> Ecto.Multi.update(
        :to_account,
        fn %{transfer: _transfer} ->
          credit = %{
            balance: Decimal.add(to_account.balance, value)
          }

          change_account(to_account, credit)
        end
      )
      |> Comadrepay.Repo.transaction()

    case transaction do
      {:ok, result} -> {:ok, result.transfer}
      {:error, _, changeset, _} -> {:error, changeset}
    end
  end
end

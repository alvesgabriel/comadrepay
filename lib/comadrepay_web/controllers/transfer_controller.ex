defmodule ComadrepayWeb.TransferController do
  use ComadrepayWeb, :controller

  alias Comadrepay.Payment
  alias Comadrepay.Payment.Transfer

  action_fallback ComadrepayWeb.FallbackController

  def transfer(conn, %{
        "from_account_id" => from_account_id,
        "to_account_id" => to_account_id,
        "value" => value
      }) do
    %{account: %{id: account_id}} = Guardian.Plug.current_resource(conn)

    if account_id == from_account_id do
      with {:ok, %Transfer{} = transfer} <-
             Payment.transfer(from_account_id, to_account_id, value) do
        conn
        |> put_status(:created)
        |> put_resp_header("location", Routes.transfer_path(conn, :show, transfer))
        |> render("show.json", transfer: transfer)
      end
    else
      {:error, :belong_user}
    end
  end

  def show(conn, %{"id" => id}) do
    transfer = Payment.get_transfer!(id)
    render(conn, "show.json", transfer: transfer)
  end

  def reversal(conn, %{"id" => id}) do
    %{account: %{id: account_id}} = Guardian.Plug.current_resource(conn)

    %{id: transfer_id} = Payment.get_transfer!(account_id, id)

    if transfer_id == id do
      with {:ok, %Transfer{} = transfer} <- Payment.reversal(id) do
        conn
        |> put_status(:no_content)
        |> render("show.json", transfer: transfer)
      end
    else
      {:error, :belong_user}
    end
  end

  def statement(conn, %{"date_begin" => date_begin, "date_end" => date_end} = _params) do
    %{account: %{id: account_id}} = Guardian.Plug.current_resource(conn)

    transfers = Payment.statemet(date_begin, date_end, account_id)

    render(conn, "index.json", transfers: transfers)
  end
end

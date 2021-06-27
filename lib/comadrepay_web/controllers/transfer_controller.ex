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
    with {:ok, %Transfer{} = transfer} <-
           Payment.transfer(from_account_id, to_account_id, value) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.transfer_path(conn, :show, transfer))
      |> render("show.json", transfer: transfer)
    end
  end

  def show(conn, %{"id" => id}) do
    transfer = Payment.get_transfer!(id)
    render(conn, "show.json", transfer: transfer)
  end

  def reversal(conn, %{"id" => id}) do
    with {:ok, %Transfer{} = transfer} <- Payment.reversal(id) do
      conn
      |> put_status(:no_content)
      |> render("show.json", transfer: transfer)
    end
  end
end

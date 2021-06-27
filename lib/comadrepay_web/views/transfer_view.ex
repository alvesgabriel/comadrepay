defmodule ComadrepayWeb.TransferView do
  use ComadrepayWeb, :view
  alias ComadrepayWeb.TransferView

  def render("index.json", %{transfers: transfers}) do
    %{data: render_many(transfers, TransferView, "transfer.json")}
  end

  def render("show.json", %{transfer: transfer}) do
    %{data: render_one(transfer, TransferView, "transfer.json")}
  end

  def render("transfer.json", %{transfer: transfer}) do
    %{
      id: transfer.id,
      from_account_id: transfer.from_account_id,
      to_account_id: transfer.to_account_id,
      value: transfer.value,
      reversaled: transfer.reversaled
    }
  end
end

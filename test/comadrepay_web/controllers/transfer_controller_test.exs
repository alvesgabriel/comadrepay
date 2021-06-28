defmodule ComadrepayWeb.TransferControllerTest do
  use ComadrepayWeb.ConnCase

  import Comadrepay.AccountsFixtures
  import Comadrepay.TransfersFixtures

  alias Comadrepay.Accounts

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(user_valid_attrs())
    user
  end

  setup %{conn: conn} do
    user = fixture(:user)
    token = Accounts.generate_user_api_token(user)

    conn = put_req_header(conn, "accept", "application/json")
    conn_auth = put_req_header(conn, "authorization", "Bearer #{token}")

    {:ok, conn: conn, conn_auth: conn_auth, user: user}
  end

  describe "POST /api/accounts/transfer" do
    test "renders transfer when data is valid", %{conn_auth: conn_auth} do
      transfer = transfer_valid()
      conn_auth = post(conn_auth, Routes.transfer_path(conn_auth, :transfer), transfer)

      data = json_response(conn_auth, 201)["data"]
      assert data["from_account_id"] == transfer.from_account_id
      assert data["to_account_id"] == transfer.to_account_id
      assert data["value"] == Decimal.to_string(transfer.value)
    end
  end

  describe "PUT /api/accounts/transfer/:id/reversal" do
    test "renders reversal transfer when data is valid", %{conn_auth: conn_auth} do
      transfer = transfer_fixture()
      conn_auth = put(conn_auth, Routes.transfer_path(conn_auth, :reversal, transfer))

      assert data = json_response(conn_auth, 204)["data"]

      assert data["from_account_id"] == transfer.to_account_id
      assert data["to_account_id"] == transfer.from_account_id
      assert data["value"] == Decimal.to_string(transfer.value)
      assert data["reversaled"] == true
    end

    test "renders reversal transfer when reversaled is true", %{conn_auth: conn_auth} do
      transfer = transfer_fixture()
      conn_auth = put(conn_auth, Routes.transfer_path(conn_auth, :reversal, transfer))

      assert json_response(conn_auth, 204)["data"]

      conn_auth = put(conn_auth, Routes.transfer_path(conn_auth, :reversal, transfer))

      assert data = json_response(conn_auth, 400)
      assert data == %{"errors" => %{"detail" => "transfer already reversaled"}}
    end
  end

  describe "GET /api/accounts/transfer?date_begin=YYYY-MM-DD HH:MI:SS&date_end=YYYY-MM-DD HH:MI:SS" do
    test "renders transfers statement when data is valid", %{conn_auth: conn_auth} do
      date_begin =
        NaiveDateTime.utc_now()
        |> NaiveDateTime.truncate(:second)
        |> to_string

      _transfer = transfer_fixture()

      dates = %{
        "date_begin" => date_begin,
        "date_end" =>
          NaiveDateTime.utc_now()
          |> NaiveDateTime.truncate(:second)
          |> to_string
      }

      conn_auth = get(conn_auth, Routes.transfer_path(conn_auth, :statement), dates)

      assert data = json_response(conn_auth, 200)["data"]
      assert data != []
    end
  end
end

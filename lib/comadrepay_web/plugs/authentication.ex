defmodule ComadrepayWeb.Plugs.Authentication do
  import Plug.Conn

  def init(token) do
    token
    |> IO.inspect()
  end

  def call(%Plug.Conn{} = conn, _default) do
    conn
    |> IO.inspect()

    conn
  end
end

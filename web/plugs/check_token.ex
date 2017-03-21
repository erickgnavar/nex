defmodule Nex.Plugs.CheckToken do
  import Plug.Conn

  alias Nex.Token

  def init(opts), do: opts

  def call(conn, _opts) do
    case get_req_header(conn, "authorization") do
      ["Token " <> token] ->
        case Token.check(token) do
          {:ok, _} -> conn
          {:error, message} -> unauthorized(conn, message)
        end
      _ ->
        unauthorized(conn, "Please provide an Authorization header value")
    end
  end

  defp unauthorized(conn, message) do
    payload = %{
      "error" => message
    }
    conn
    |> put_resp_header("content-type", "application/json")
    |> resp(401, Poison.encode!(payload))
    |> halt
  end
end

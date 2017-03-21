defmodule Nex.CheckTokenTest do
  use Nex.ConnCase

  alias Nex.Plugs.CheckToken
  alias Nex.Token

  @opts %{}

  setup %{conn: conn} do
    conn = conn
    |> put_req_header("accept", "application/json")
    {:ok, conn: conn}
  end

  test "unauthorized when the header is not provided", %{conn: conn} do
    conn = CheckToken.call(conn, @opts)
    assert json_response(conn, 401)["error"] == "Please provide an Authorization header value"
  end

  test "unauthorized when token does not exists", %{conn: conn} do
    conn = conn
    |> put_req_header("authorization", "Token not_found_token")
    |> CheckToken.call(@opts)
    assert json_response(conn, 401)["error"] == "Token not found"
  end

  test "authorized with correct token value", %{conn: conn} do
    token = Token.new
    conn = conn
    |> put_req_header("authorization", "Token #{token.value}")
    |> CheckToken.call(@opts)
    refute conn.status == 401
  end
end

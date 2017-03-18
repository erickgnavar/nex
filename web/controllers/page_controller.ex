defmodule Nex.PageController do
  use Nex.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end

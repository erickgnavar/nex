defmodule Nex.PostController do
  use Nex.Web, :controller

  alias Nex.{Post, Tag}

  plug Nex.Plugs.CheckToken when action in[:create, :update, :delete]

  def index(conn, _params) do
    posts = Post |> Post.latest |> Repo.all
    render(conn, "index.json", posts: posts)
  end

  def create(conn, %{"post" => post_params}) do
    tags = Tag |> Tag.by_ids(Map.get(post_params, "tags", [])) |> Repo.all
    changeset = Post.changeset(%Post{}, post_params |> Map.put("tags", tags))

    case Repo.insert(changeset) do
      {:ok, post} ->
        # broadcast info to all the sockets
        rendered_post = Nex.PostView.render("post.json", %{post: post})
        Nex.Endpoint.broadcast("news:lobby", "new:post", rendered_post)
        conn
        |> put_status(:created)
        |> put_resp_header("location", post_path(conn, :show, post))
        |> render("show.json", post: post)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Nex.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    post = Repo.get!(Post, id) |> Repo.preload(:tags)
    render(conn, "show.json", post: post)
  end

  def update(conn, %{"id" => id, "post" => post_params}) do
    post = Repo.get!(Post, id) |> Repo.preload(:tags)
    changeset = Post.changeset(post, post_params)

    case Repo.update(changeset) do
      {:ok, post} ->
        render(conn, "show.json", post: post)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Nex.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    post = Repo.get!(Post, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(post)

    send_resp(conn, :no_content, "")
  end
end

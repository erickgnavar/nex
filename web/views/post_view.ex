defmodule Nex.PostView do
  use Nex.Web, :view

  def render("index.json", %{posts: posts}) do
    %{data: render_many(posts, Nex.PostView, "post.json")}
  end

  def render("show.json", %{post: post}) do
    %{data: render_one(post, Nex.PostView, "post.json")}
  end

  def render("post.json", %{post: post}) do
    %{
      id: post.id,
      title: post.title,
      body: post.body,
      tags: render_tags(post.tags)
    }
  end

  defp render_tags(tags) do
    tags
    |> Enum.map(fn tag ->
      Nex.TagView.render("tag.json", %{tag: tag})
    # use this way to avoid add "data" key in result
    end)
  end
end

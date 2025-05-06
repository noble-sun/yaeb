defmodule AppWeb.PostLive.Index do
  use AppWeb, :live_view

  alias App.Blog
  alias App.Blog.Post

  on_mount {AppWeb.UserAuth, :ensure_authenticated}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :posts, [])}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :root, _params) do
    socket
    |> assign(:page_title, "Blog")
    |> assign(:post, nil)
    |> stream(:posts, [], reset: true)
    |> stream(:posts, Blog.list_posts())
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    post = Blog.get_post!(id)

    if post.user_id != socket.assigns.current_user.id do
      Phoenix.LiveView.redirect(socket, to: ~p"/posts")
    else
      socket
      |> assign(:page_title, "Edit Post")
      |> assign(:post, post)
    end
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Post")
    |> assign(:post, %Post{})
  end

  defp apply_action(socket, :index, _params) do
    posts = Blog.list_user_posts(socket.assigns.current_user)

    socket
    |> assign(:page_title, "Listing Posts")
    |> assign(:post, nil)
    |> stream(:posts, [], reset: true)
    |> stream(:posts, posts)
  end

  @impl true
  def handle_info({AppWeb.PostLive.FormComponent, {:saved, post}}, socket) do
    {:noreply, stream_insert(socket, :posts, post)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    post = Blog.get_post!(id)

    if post.user_id != socket.assigns.current_user.id do
      {:noreply, 
        socket
        |> put_flash(:error, "You can't delete another person's post")
        |> push_navigate(to: ~p"/posts")}
    else 
      {:ok, _} = Blog.delete_post(socket.assigns.current_user, post)

      {:noreply, stream_delete(socket, :posts, post)}
    end
  end
end

defmodule AppWeb.PostLive.Show do
  use AppWeb, :live_view

  alias App.Blog

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    post = Blog.get_post_with_comments!(id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:post, post)
     |> assign(:comments, post.comments)
     |> assign_new(:comment_changeset, fn ->
          to_form(Blog.change_comment(%Blog.Comment{}))
        end)
    }
  end

  @impl true
  def handle_event("save_comment", %{"comment" => comment_params}, socket) do
    user = socket.assigns.current_user
    post = socket.assigns.post

    attrs = Map.merge(comment_params, %{"user_id" => user.id, "post_id" => post.id})

    case Blog.create_comment(attrs) do
      {:ok, _comment} ->
        comments = Blog.list_comments_for_post(post.id)
        {:noreply, 
          assign(
            socket,
            comments: comments,
            comment_changeset: Blog.change_comment(%Blog.Comment{})
          )
        }

      {:error, changeset} ->
        {:noreply, assign(socket, comment_changeset: changeset)}
    end
  end

  defp page_title(:show), do: "Show Post"
  defp page_title(:edit), do: "Edit Post"
end

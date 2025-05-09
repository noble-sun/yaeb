defmodule AppWeb.PostLive.Show do
  use AppWeb, :live_view

  alias App.Blog

  @impl true
  def mount(params, _session, socket) do
    post = Blog.get_post_with_comments!(params["id"])

    {:ok, stream(socket, :comments, post.comments)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    post = Blog.get_post_with_comments!(id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:post, post)
     |> assign(:editing_comment, nil)
     |> assign_new(:comment_changeset, fn ->
          to_form(Blog.change_comment(%Blog.Comment{}))
        end)
    }
  end

  def handle_info({:delete_comment, id}, socket) do
    comment = Blog.get_comment!(id)

    if comment.user_id == socket.assigns.current_user.id do
      {:ok, _} = Blog.delete_comment(socket.assigns.current_user, comment)
      {:noreply, stream_delete(socket, :comments, comment)}
    else
      {:noreply,
        socket
        |> put_flash(:error, "You can't delete another person's comment")
      }
    end
  end


  defp page_title(:show), do: "Show Post"
  defp page_title(:edit), do: "Edit Post"
end

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
     |> assign(:editing_comment, nil)
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

  def handle_event("edit_comment", %{"id" => id}, socket) do
    comment = Blog.get_comment!(id)

    if socket.assigns.current_user.id == comment.user_id do
      changeset = Blog.change_comment(comment)

      {:noreply,
        socket
        |> assign(:comment_changeset, changeset)
        |> assign(:editing_comment, comment)
      }
    else
      {:noreply,
        socket
        |> put_flash(:error, "You can't edit another person's comment")
      }
    end
  end

  def handle_event("update_comment", %{"comment" => comment_params}, socket) do
    user = socket.assigns.current_user
    case Blog.update_comment(user, socket.assigns.editing_comment, comment_params) do
      {:ok, _comment} ->
        {:noreply,
          socket
          |> put_flash(:info, "Comment Updated")
          |> assign(:editing_comment, nil)
          |> assign(:comment_changeset, Blog.change_comment(%Blog.Comment{}))
          |> assign_comments()
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :comment_changeset, changeset)}
    end
  end

  defp page_title(:show), do: "Show Post"
  defp page_title(:edit), do: "Edit Post"

  defp assign_comments(socket) do
    post = Blog.get_post_with_comments!(socket.assigns.post.id)
    assign(socket, :comments, post.comments)
  end
end

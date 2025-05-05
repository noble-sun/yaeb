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

  @impl true
  def handle_event("save_comment", %{"comment" => comment_params}, socket) do
    user = socket.assigns.current_user
    post = socket.assigns.post

    attrs = Map.merge(comment_params, %{"user_id" => user.id, "post_id" => post.id})

    case Blog.create_comment(attrs) do
      {:ok, comment} ->
        comment = comment |> App.Repo.preload(:user)
        {:noreply, 
          socket
          |> stream_insert(:comments, comment)
          |> assign(:comment_changeset, Blog.change_comment(%Blog.Comment{}))
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
      {:ok, comment} ->
        comment = comment |> App.Repo.preload(:user)
        {:noreply,
          socket
          |> put_flash(:info, "Comment Updated")
          |> assign(:editing_comment, nil)
          |> assign(:comment_changeset, Blog.change_comment(%Blog.Comment{}))
          |> stream_insert(:comments, comment, at: -1)
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :comment_changeset, changeset)}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
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

defmodule AppWeb.PostLive.CommentsComponent do
  use AppWeb, :live_component

  alias App.Blog

  @impl true
  def render(assigns) do
    ~H"""
  <div>
  <h3> Comments</h3>

  <div id="comments" phx-update="stream">
  <%= for {dom_id, comment} <- @streams.comments do %>
    <div id={dom_id}>
      <p>
        <strong><%= comment.user.name %>:</strong>
        <%= comment.body %>
      </p>
      <a href="#comment-form">
        <button :if={@current_user.id == comment.user_id}
          phx-value-id={comment.id}
          phx-click="edit_comment"
          phx-target={@myself}
        > Edit </button>
      </a>
      <button :if={@current_user.id == comment.user_id}
        phx-click="delete"
        phx-value-id={comment.id}
        phx-target={@myself}
      > Delete </button>
    </div>
  <% end %>
  </div>

  <.simple_form :let={f}
    for={@comment_changeset}
    id="comment-form"
    phx-submit={@editing_comment && "update_comment" || "save_comment"}
    phx-target={@myself}
    as="comment"
  >
    <.input field={f[:body]} type="textarea" />

    <:actions>
      <.button phx-disable-with="Saving...">
        <%= if @editing_comment, do: "Update Comment", else: "Post Comment" %>
      </.button>
    </:actions>
  </.simple_form>
  </div>

    """
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
    send(self(), {:delete_comment, id})
    {:noreply, socket}
  end
end

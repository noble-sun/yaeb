defmodule App.Blog do
  @moduledoc """
  The Blog context.
  """

  import Ecto.Query, warn: false
  alias App.Repo

  alias App.Blog.Comment
  alias App.Blog.Post
  alias App.Accounts

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts do
    Repo.all(Post)
    |> Repo.preload(:user)
  end

  @doc """
  Returns all the user's posts.

  ## Ecamples

    iex> list_user_posts(%Accounts.User{id: user_id})
    [%Post{user_id: user_id, title: 'My first post!'}, ...]
  """
  def list_user_posts(%Accounts.User{id: user_id}) do
    Post
    |> where(user_id: ^user_id)
    |> Repo.all()
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id), do: Repo.get!(Post, id)

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(attrs \\ %{}, %Accounts.User{id: user_id}) do
    %Post{}
    |> Post.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(%Accounts.User{id: user_id}, %Post{} = post, attrs) do
    if post.user_id == user_id do
      post
      |> Post.changeset(attrs)
      |> Repo.update()
    else
      {:error, :unauthorized}
    end
  end

  def update_post(%Accounts.User{}, %Post{}, attrs), do: {:error, :unauthorized}

  @doc """
  Deletes a post.

  ## Examples

      iex> delete_post(%Accounts.User{id: user_id}, %Post{user_id: user_id} = post)
      {:ok, %Post{}}

      iex> delete_post(%Accounts.User{}, post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Accounts.User{id: user_id}, %Post{} = post) do
    if post.user_id == user_id do
      Repo.delete(post)
    else
      {:error, :unauthorized}
    end
  end

  def delete_post(%Accounts.User{}, %Post{}, attrs), do: {:error, :unauthorized}

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{data: %Post{}}

  """
  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end

  def list_comments_for_post(post_id) do
    Comment
    |> where([c], c.post_id == ^post_id)
    |> Repo.all()
    |> Repo.preload(:user)
  end

  def get_comment!(id), do: Repo.get!(Comment, id)

  def create_comment(attrs \\ %{}) do
    %Comment{}
    |> Comment.changeset(attrs)
    |> Repo.insert()
  end

  def change_comment(%Comment{} = comment, attrs \\ %{}) do
    Comment.changeset(comment, attrs)
  end

  def get_post_with_comments!(id) do
    Repo.get!(Post, id)
    |> Repo.preload(comments: [:user])
  end

  def update_comment(%Accounts.User{id: user_id}, %Comment{} = comment, attrs) do
    if comment.user_id == user_id do
      comment
      |> Comment.changeset(attrs)
      |> Repo.update()
    else
      {:error, :unauthorized}
    end
  end
end

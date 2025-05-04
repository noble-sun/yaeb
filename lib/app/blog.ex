defmodule App.Blog do
  @moduledoc """
  The Blog context.
  """

  import Ecto.Query, warn: false
  alias App.Repo

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
    attrs = Map.put(attrs, "user_id", user_id)
    |> IO.inspect(label: "=================== ATTRS CREATE_POST ========================")

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
    post
    |> IO.inspect(label: "=================== POST ========================")
    user_id
    |> IO.inspect(label: "=================== USER_ID ========================")
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
end

defmodule App.Blog.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :title, :string
    field :body, :string

    belongs_to :user, App.Accounts.User
    has_many :comments, App.Blog.Comment, on_delete: :nilify_all

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:user_id, :title, :body])
    |> validate_required([:user_id, :title, :body])
  end
end

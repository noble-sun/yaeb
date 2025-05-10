# Yet Another Elixir Blog

A simple blog where you can post and comment anything you want.

# Tech Stack
- **Version Control**: [Git](https://git-scm.com/)
- **Language**: [Elixir 1.18](https://elixir-lang.org/install.html)
- **Framework**: [Phoenix 1.7](https://www.phoenixframework.org/)
- **Database:** [PostgreSQL 17.2](https://www.postgresql.org/download/)

# Build and Installation
### Prerequisites
Install [git](https://git-scm.com/downloads).

Install [Docker](https://docs.docker.com/get-started/get-docker/) and [Docker Compose](https://docs.docker.com/compose/install/), 
or have the tech stack installed localy on your machine.

# Run the Project
Clone the project to your local machine:
```bash
git clone git@github.com:noble-sun/yaeb.git
```
Go to the cloned directory:
```bash
cd yaeb
```
Run the commands to install dependencies, set up database and run server, respectively:
```bash
mix deps.get
mix ecto.setup
mix phx.server
```

You can also run this project using docker:
```bash
docker compose run --rm --service-ports phoenix bash
```

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

# Future Improvements
- Comment threads
- Add images and GIFs
- Markdown for posts
- See other users posts and comments
- Pagination/infinite scroll on posts list
- Notifications for post owner
- Follow other users
- Search
- Tags
- Save posts

## Learn more
  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix

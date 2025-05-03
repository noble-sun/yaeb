FROM elixir:1.18

# Install Node.js for Phoenix assets and postgres
RUN apt-get update && \
    apt-get install -y curl nodejs npm inotify-tools postgresql-client

# Install Hex, Rebar and Phoenix installer
RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix archive.install hex phx_new --force
    
WORKDIR /app

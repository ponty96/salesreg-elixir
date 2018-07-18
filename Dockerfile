FROM elixir:1.6
MAINTAINER ponty96
ENV UPDATED_AT 2018-07-18

# Set the time zone
RUN echo "Africa/Lagos" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata
# VOLUME /etc/timezone /etc/localtime

# Install git and basic mix dependencies
RUN apt-get update -y
RUN apt-get install -y git build-essential
RUN apt-get update && apt-get install --yes postgresql-client
RUN apt-get install -y inotify-tools # For live reloading.
RUN apt-get install -y imagemagick

ADD . /app
RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix archive.install --force https://github.com/phoenixframework/archives/raw/master/phx_new.ez
WORKDIR /app
EXPOSE 5000
# Now get our dependencies and compile them for both environments
# Note that we don't compile so that every run is a fresh build *of the app*
RUN mix deps.get
RUN mix deps.compile
RUN MIX_ENV=test mix deps.compile


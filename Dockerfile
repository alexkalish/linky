FROM ruby:2.6

# Add the Postgres apt repo (including lsb-release, which is needed to pick the right repo).
RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends lsb-release && \
  wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
  echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -sc)-pgdg main" > /etc/apt/sources.list.d/PostgreSQL.list

# Always do an apt-get update when installing a package, in order to avoid getting
# a cached package list.
RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends \
  nodejs \
  postgresql-client-11

# Copy just the Gemfile and run bundle install first, so that the step can be properly
# cached.
COPY Gemfile* /usr/src/app/

# Set the working directory to the app.
WORKDIR /usr/src/app/

# Install all of our dependencies.
RUN bundle install

# Now, copy the contents of the app into the image.
COPY . /usr/src/app/

# Start the rails server, binding to all network interfaces.
CMD ["bin/rails", "s", "-b", "0.0.0.0"]

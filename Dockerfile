# syntax = docker/dockerfile:1

# Use a Ruby base image
ARG RUBY_VERSION=3.2.2
FROM ruby:$RUBY_VERSION-slim AS base

LABEL fly_launch_runtime="rails"

# Set app working directory
WORKDIR /rails

# Set environment variables
ENV BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test" \
    RAILS_ENV="production"

# Update gem system and install bundler
RUN gem update --system --no-document && \
    gem install -N bundler


# -----------------------
# Build Stage
# -----------------------
FROM base AS build

# Install system dependencies for building gems and JS
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential curl libpq-dev node-gyp pkg-config python-is-python3 git

# Install Node.js manually
ARG NODE_VERSION=20.14.0
ENV PATH=/usr/local/node/bin:$PATH
RUN curl -sL https://github.com/nodenv/node-build/archive/master.tar.gz | tar xz -C /tmp/ && \
    /tmp/node-build-master/bin/node-build "${NODE_VERSION}" /usr/local/node && \
    rm -rf /tmp/node-build-master

# Copy Gemfiles and install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    bundle exec bootsnap precompile --gemfile && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

# Install JS dependencies
COPY package.json package-lock.json ./
RUN npm install

# Copy app source code
COPY . .

# Precompile app code for production (no assets needed for API mode)
RUN bundle exec bootsnap precompile app/ lib/


# -----------------------
# Final Stage
# -----------------------
FROM base

# Install minimal runtime dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl imagemagick postgresql-client && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives

# Copy everything from the build stage
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Create needed dirs and a non-root user
RUN mkdir -p db log tmp && \
    groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails /rails

# Use the non-root user for security
USER rails

# Set production env vars
ENV RAILS_LOG_TO_STDOUT="1" \
    RAILS_SERVE_STATIC_FILES="true" \
    SECRET_KEY_BASE="69c7d7389bbb003e21265b47e0a66d950c4018fee485abcb1355bfddd59a8fdb0d5573a94357c25be6eefe584c591ae067085169b36dfdea811422036d7bf35d"

# Entrypoint for setup tasks
ENTRYPOINT ["bin/docker-entrypoint"]

# Run Rails server by default
EXPOSE 3000
CMD ["bin/rails", "server", "-b", "0.0.0.0"]
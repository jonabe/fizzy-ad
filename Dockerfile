# Base image matching Fizzy's Ruby version
FROM ruby:3.4.7-slim

# Install system dependencies
RUN apt-get update -qq && \
    apt-get install -y \
      build-essential \
      libpq-dev \
      libyaml-dev \
      libvips \
      nodejs \
      git \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy Gemfile and install dependencies
COPY Gemfile Gemfile.lock ./
RUN bundle lock --add-platform aarch64-linux && bundle install

# Copy application code
COPY . .

# Precompile assets (if needed)
# RUN bundle exec rails assets:precompile

# Expose port 3000 (Rails default)
EXPOSE 3000

# Start Rails server
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]

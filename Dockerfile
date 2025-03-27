FROM ruby:3.3.4-slim
WORKDIR /app

# Instalar herramientas de desarrollo
RUN apt-get update -qq && \
  apt-get install -y build-essential && \
  rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

EXPOSE 9292
CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "--port", "9292"]

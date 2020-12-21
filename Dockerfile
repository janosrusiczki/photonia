# Dockerfile - Development environment
FROM ruby:2.6.6
LABEL maintainer="janos.rusiczki@gmail.com"

# nodejs
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg -o /root/yarn-pubkey.gpg && apt-key add /root/yarn-pubkey.gpg
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install -y --no-install-recommends nodejs yarn

# rails
RUN mkdir /photonia
COPY . /photonia
WORKDIR /photonia

RUN yarn install --check-files
RUN gem install bundler
RUN bundle install

CMD bundle exec rails server -b 0.0.0.0
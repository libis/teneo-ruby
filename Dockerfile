# Base image
ARG RUBY_VERSION=3.1
ARG RUBY_IMAGE_VARIANT=slim-bookworm
ARG BUNDLER_VERSION=2.2.15
ARG GEMS_PATH=/bundle-gems

FROM ruby:${RUBY_VERSION}-slim

# Silence apt
RUN dpkg-reconfigure debconf --frontend=noninteractive

# Install common packages
RUN apt-get update -qq \
 && apt-get install -qqy --no-install-recommends \
        build-essential \
        gnupg2 \
        curl \
        less \
        git \
        wget \
        libsqlite3-dev \
        libaio1 \
        vim \
        postgresql-client \
 && apt-get clean \
 && rm -fr /var/cache/apt/archives/* \
 && rm -fr /var/lib/apt/lists/* /tmp/* /var/tmp* \
 && truncate -s 0 /var/log/*log

# Copy Entrypoint script
COPY start.sh /usr/local/bin/start.sh
RUN chmod 755 /usr/local/bin/start.sh

# Location of the installed gems
ARG GEMS_PATH
ENV GEMS_PATH=${GEMS_PATH}
VOLUME ${GEMS_PATH}

# Prepare ruby environment
ENV LANG=C.UTF-8 \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3 \
    BUNDLE_PATH=${GEMS_PATH}

# Upgrade RubyGems and install required Bundler version
ARG BUNDLER_VERSION
COPY Gemfile .
RUN gem update --system && \
    gem install bundler:${BUNDLER_VERSION} && \
    bundle install

ENTRYPOINT [ "/usr/local/bin/start.sh" ]
CMD [ "irb" ]

# Base image
ARG RUBY_VERSION=2.6

FROM ruby:${RUBY_VERSION}-slim-buster

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
        libaio1 \
    && apt-get clean \
    && rm -fr /var/cache/apt/archives/* \
    && rm -fr /var/lib/apt/lists/* /tmp/* /var/tmp* \
    && truncate -s 0 /var/log/*log

# Install some Rails requirements NodeJS and yarn

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update -qq \
    && apt-get install -qqy --no-install-recommends \
        nodejs \
        yarn \
    && apt-get clean \
    && rm -fr /var/cache/apt/archives/* \
    && rm -fr /var/lib/apt/lists/* /tmp/* /var/tmp* \
    && truncate -s 0 /var/log/*log

ARG PG_VERSION=12

# Install PostgreSQL client
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
    && echo "deb http://apt.postgresql.org/pub/repos/apt/ buster-pgdg main" > /etc/apt/sources.list.d/postgres.list \
    && apt-get update -qq \
    && apt-get install -qqy --no-install-recommends \
        libpq-dev \
        postgresql-client-$PG_VERSION \
    && apt-get clean \
    && rm -fr /var/cache/apt/archives/* \
    && rm -fr /var/lib/apt/lists/* /tmp/* /var/tmp* \
    && truncate -s 0 /var/log/*log

# Location of the Oracle instance client installation
ARG ORACLIENT_PATH=/oracle-client
VOLUME ${ORACLIENT_PATH}

# Upgrade RubyGems and install required Bundler version
ARG BUNDLER_VERSION=2.1.4

RUN gem update --system && \
    gem install bundler:$BUNDLER_VERSION

# Copy Entrypoint script
COPY start.sh /usr/local/bin/start.sh
RUN chmod 755 /usr/local/bin/start.sh

# Location of the installed gems
ARG GEMS_PATH=/bundle-gems
VOLUME ${GEMS_PATH}

# Prepare ruby environment
ENV LANG=C.UTF-8 \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3 \
    LD_LIBRARY_PATH=${ORACLIENT_PATH} \
    BUNDLE_PATH=${GEMS_PATH} \
    RUBY_ENV=production

ENTRYPOINT [ "/usr/local/bin/start.sh" ]
CMD [ "bundle", "exec", "irb" ]

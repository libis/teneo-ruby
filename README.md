# teneo-ruby
Base docker ruby image for Teneo docker images

## Description
This image is not so usefull on its own. It is considered a base image to create other images from.
The image contains a ruby installation and Postresql client.

The image's entrypoint script is located in '/usr/local/bin/start.sh' and will start your command with ``bundle exec``. It can optionally run a ``bundle install`` or ``bundle update`` first.

## Usage
Use this image as a base image in your Dockerfile like so:

```docker
FROM libis/teneo-ruby:latest
...
```

If you would like to run your application internally as a different user and specify a user and group
id for that user, you could create your Dockerfile like this:

```docker
FROM libis/teneo-ruby:latest

# Create application user
ARG UID=1000
ARG GID=1000
ARG HOME_DIR=/teneo

RUN groupadd --gid ${GID} teneo
RUN useradd --home-dir ${HOME_DIR} --create-home --no-log-init --uid ${UID} --gid ${GID} teneo

# Switch to application user 
USER teneo
WORKDIR ${HOME_DIR}

# Copy application data
COPY . ${HOME_DIR}

# Start application
CMD ["rack", "up"]
```

# Build Configuration

The following build arguments are defined:

-   `RUBY_VERSION` *Ruby version*
-   `BUNDLER_VERSION` *Bundler gem version*
-   `GEMS_PATH` *Default location of installed gems*

## Ruby

The build argument `RUBY_VERSION` selects the ruby version that will be installed. Note that this 
image uses the official Ruby docker images a base image. The Ruby version supplied to this image's 
build command will need to refer to an existsing Ruby base image tag. The `RUBY_VERSION` value will 
be appended with `-slim` to form the base image tag.

The `BUNDLER_VERSION` build argument determines the version of the `bundle` gem that will be installed and selected.

The gems can be installed/updated during startup of the container. In order to cache the installed 
gems and possible share the gem installation amongst multiple containers, a separate volume is defined.
The internal mapping of this volume is determined by the build argument `GEMS_PATH`. It's default 
value is `/bundle-gems`.

# Run-time configuration

## Environment variables
The following environment variables are defined and set explicitly in the image:

-   `LANG`

    Set to `C.UTF-8` by default and defines the locale.

-   `BUNDLE_JOBS`

    Determines the number of parallel jobs that the bundler may use when updating the gems. Default setting is `4`.

-   `BUNDLE_RETRY`

    The number of times bundler will retry to install a gem when a connection problem occurs.

-   `BUNDLE_PATH`

    The location where gems are installed. This is set to the value of the `GEMS_PATH` build argument
    by default.

## Gems

It is can be a good practice to keep installed gems in separate volume. This has several advantages:

* The image size is reduced as the storage for the gems is not part of the image build.
* The image build time is reduced.
* The gems can be cached by persisting the volume reducing the `bundle install` time after the 
  initial run. Make sure you create a docker volume and bind it to the `GEMS_PATH` for this.
* The installed gems can be shared by multiple similar applications reducing required size and 
  initialization time even further.

The internal mapping for the Gem installation volume can be set with the build argument `GEMS_PATH`.

This is however optional. It is for instance perfectly fine to create your image based of this image with locally installed gems like so:
```docker
# Build arguments
ARG BASE_IMAGE
ARG APP_DIR=/app

FROM ${BASE_IMAGE}

WORKDIR ${APP_DIR}
# Configure bundler

RUN bundle config set --local deployment 'true'
RUN bundle config set --local path 'vendor/bundle'

CMD ["app.rb"]
```
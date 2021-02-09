# teneo-ruby
Base docker ruby image for Teneo docker images

## Description
This image is not so usefull on its own. It is considered a base image to create other images from.
The image contains a ruby installation and Postresql client. The image is prepared to install an Oracle client as well.


The image's entrypoint script is located in '/usr/local/bin/start.sh' and will update your bundle if required and start your command.

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
CMD ["bundle", "exec", "rack", "up"]
```

# Build Configuration

The following build arguments are defined:

-   `RUBY_VERSION` *Ruby version*
-   `BUNDLER_VERSION` *Bundler gem version*
-   `GEMS_PATH` *Location of installed gems*
-   `RUBY_ENV` *default application environment*
-   `PG_VERSION` *Postgres client version*
-   `ORACLIENT_PATH` *Location of the mounted oracle client package*

## Ruby

The build argument `RUBY_VERSION` selects the ruby version that will be installed. Note that this 
image uses the official Ruby docker images a base image. The Ruby version supplied to this image's 
build command will need to refer to an existsing Ruby base image tag. The `RUBY_VERSION` value will 
be appended with `-slim-buster` to form the base image tag.

The `BUNDLER_VERSION` build argument determines the version of the `bundle` gem that will be installed and selected.

The gems will be installed/updated during startup of the container. In order to cache the installed 
gems and possible share the gem installation amongst multiple containers, a separate volume is defined.
The internal mapping of this volume is determined by the build argument `GEMS_PATH`. It's default 
value is `/bundle-gems`.

The build argument `RUBY_ENV` sets the default value for the environment variable `RUBY_ENV`.

## Postgresql version

The build argument `PG_VERSION` determines the version of Postgres client that will be installed.
The installation is performed via `apt install` using the Postgres repository. You should only 
specify the major version number here as the client package is only identified with the major version.

## Oracle client

If the `ruby-oci8` gem is required, an Oracle client installation is required for this gem to work.
To reduce the size of the image, an Oracle client installed on the host can be used by binding a
volume to it. The internal mapping of this volume can be changed by setting the `ORACLIENT_PATH` build 
argument. The default value is `/oracle-client`.

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

-   `RUBY_ENV`

    The application environment. The default value is determined by the `RUBY_ENV` build argument.

## Gems

It is considered good practice to keep installed gems in separate volume. This has several advantages:

* The image size is reduced as the storage for the gems is not part of the image build.
* The image build time is reduced.
* The gems can be cached by persisting the volume reducing the `bundle install` time after the 
  initial run. Make sure you create a docker volume and bind it to the `GEMS_PATH` for this.
* The installed gems can be shared by multiple similar applications reducing required size and 
  initialization time even further.

The internal mapping for the Gem installation volume can be set with the build argument `GEMS_PATH`.

Note that the default ENTRYPOINT script will cause the installed gems to be updated when the container 
is started and before your application is started. It will however only do so when it decides that 
an install/update is required (thanks to `bundle check`).

## Oracle client

In order to use the ruby-oci8 gem, you need to install an Oracle client (e.g. Oracle InstantClient).

Due to licensing constraints and in order to keep the image size small, it is not advised to embed 
an installed Oracle InstantClient in your images. Instead you can mount a volume with the Oracle 
InstantClient installed on the host. You should then also add it to the LD_LIBRARY_PATH environment
variable:

```
docker run -v ${HOME}/oracleclient:/opt/oracle/client -e LD_LIBRARY_PATH=/opt/oracle/client libis/teneo-ruby
```


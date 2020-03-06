# teneo-ruby
Base docker ruby image for Teneo docker images

## Description
This image is not so usefull on its own. It is considered a base image to create other images from.
The image contains a ruby installation and Postresql client. It also allows to include an Oracle client
installation (e.g. Oracle InstantClient) to support the installation of a ruby-oci8 gem.

The image creates a user 'teneo' and groupu 'teneo' and will run your application as that user from its own home directory '/teneo'.

The image's entrypoint script is located in '/usr/local/bin/start.sh' and will update your bundle if required and start your command.

## Usage
Use this image as a base image in your Dockerfile like so:

```docker
FROM teneo/ruby:latest
COPY . /teneo
CMD ["bundle", "exec", "myapp.rb"]
```

# Build Configuration

The following build arguments are defined:

-   `UID` *internal user id*
-   `GID` *internal group id*
-   `HOME_DIR` *internal user home dir and application dir*
-   `PG_VERSION` *Postgres client version*
-   `ORACLIENT_PATH` *Location of the mounted oracle client package*
-   `RUBY_VERSION` *Ruby version*
-   `BUNDLER_VERSION` *Bundler gem version*
-   `GEMS_PATH` *Location of installed gems*
-   `RUBY_ENV` *default application environment*

## User settings
As mentioned above the application will run as the 'teneo:teneo' user. You can select the ids of this 
user and group by setting the `UID` and `GID` build arguments. You may want to run your dockerized 
ruby application with the same id as the host user running the container like so:

```
docker build \
    --build-arg UID=$(id -u ${USER}) \
    --build-arg GID=$(id -g ${USER}) \
    ....
```
The internal user id and group id are set when the image is built. It cannot be changed at run-time.

Likewise, it the default user's home and application directory `/teneo` does not suit you, it can be
changed by setting the build argument `HOME_DIR`.

## Postgresql version

The build argument `PG_VERSION` determines the version of Postgres client that will be installed.
The installation is performed via `apt install` using the Postgres repository. You should only 
specify the major version number here as the client package is only identified with the major version.

## Oracle client

If the `ruby-oci8` gem is required, an Oracle client installation is required for this gem to work.
To reduce the size of the image, an Oracle client installed on the host can be used by binding a
volume to it. The internal mapping of this volume can be changed by setting the `ORACLIENT_PATH` build 
argument. The default value is `/oracle-client`.

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

# Run-time configuration

## Environment variables
The following environment variables are defined and set explicitly in the image:

-   `LANG`

    Set to `C.UTF-8` by default and defines the locale.

-   `BUNDLE_JOBS`

    Determines the number of parallel jobs that the bundler may use when updating the gems. Default setting is `4`.

-   `BUNDLE_RETRY`

    The number of times bundler will retry to install a gem when a connection problem occurs.

-   `LD_LIBRARY_PATH`

    The default location(s) where share libraries will be searched at run-time. It is by default set   
    to the path of the Oracle client: `/oracle-client`

-   `BUNDLE_PATH`

    The location where gems are installed. This is set to the value of the `GEMS_PATH` build argument
    by default.

-   `RUBY_ENV`

    The application environment. The default value is determined by the `RUBY_ENV` build argument.

## Volumes

Two volumes are defined in this image. Their useage is explained below.

### Oracle client

Due to licensing constraints and in order to keep the image size small, it is not advised to embed 
an installed Oracle InstantClient in your images. Instead this image is expected to mount a volume 
with the Oracle InstanceClient installed on the host. The default internal mapping for this volume 
is defined by the build argument `ORACLIENT_PATH`.

### Gems

It is considered best practice to install gems in a volume. This has several advantages:

* The image size is reduced as the storage for the gems is not part of the image build.
* The image build time is reduced.
* The gems can be cached by persisting the volume reducing the `bundle install` time after the 
  initial run.
* The installed gems can be shared by multiple similar applications reducing required size and 
  initialization time even further.

The internal mapping for the Gem installation volume can be set with the build argument `GEMS_PATH`.

Note that the default ENTRYPOINT script will cause the installed gems to be updated when the container 
is started and before your application is started. It will however only do so when it decides that 
an install/update is required (thanks to `bundle check`).
# The Dlang Online Tour

[![Build Status](https://travis-ci.org/dlang-tour/core.svg?branch=master)](https://travis-ci.org/dlang-tour/core)

This is the [D language](https://dlang.org) online tour which
provides an online introduction to this great system programming language
with examples that can be edited, compiled and run online.

The most recent version of this tour can be seen here: http://tour.dlang.org.

### Running offline

The tour can be downloaded for offline access:

```sh
git clone --recursive https://github.com/dlang-tour/core && cd core
git submodule foreach git pull origin master
dub
```

This requires DUB - D's package manager. DUB is part of the [release installer and archives](https://dlang.org/download.html).

### Specifying a language directory

For translator it's often convenient to clone their directory and run the tour
only with their language.
A custom language can be loaded directly using the `-l` / `--lang-dir` option
with the path to the directoy of the to be loaded language:

```sh
dub fetch dlang-tour # only once
dub run dlang-tour -- --lang-dir .
```

## Add Content

This repository contains the application that runs the tour.
Please refer to [english](https://github.com/dlang-tour/english)
content or [another language](https://github.com/dlang-tour).

Further information on how to add or change existing content can also be found
in the [CONTRIBUTING.md](CONTRIBUTING.md).

## Compile & Run

On a minimal Ubuntu system the following command will install the system packages needed to run all examples:

```sh
apt update && apt install \
    curl xz-utils unzip gnupg `# Needed for the install.sh script` \
    build-essential `# C toolchain for compiling and linking` \
    libssl-dev libevent-dev `# Vibe-d network dependencies`\
    libopenblas-dev `# lubeck computer library dependency` \
    libxml++2.6-2v5 zlib1g-dev `# LDC dependencies`
```

Make sure [dub](http://code.dlang.org/download) is installed and simply run `dub` in
the `dlang-tour` folder:

```sh
git clone --recursive https://github.com/dlang-tour/core && cd core
dub
```

You might want to change the settings in `config.yml` to change
the ports the tour is listening to.

### OpenSSL 1.1

If you see linker errors regarding OpenSSL/1.1, try:

```sh
dub --override-config="vibe-d:tls/openssl-1.1"
```

## Compiling & running of user source code

The source code on the tour can be compiled and then executed online and its output returned
to the user. Therefore three different types of **execution drivers** have been
implemented within the dlang-tour:

 * `off`: no online compilation allowed. If the user hits ***Runs*** an error message
   will be returned.
 * `stupidlocal`: an unsafe method that just runs `rdmd` on the local host system
   and returns its output. ***Very unsafe*** and musn't ever be used in production!
 * `docker`: runs `dmd` within a special Docker container ([core-exec](https://github.com/dlang-tour/core-exec))
   and returns its output. The driver imposes the Docker container memory and
   execution time limits. Additional configurations options available in `config.yml`.

The execution driver is set in `config.yml`.

Caching of the program output can also be enabled in `config.yml` (`exec.cache = true`). Caching
will only be enabled for the built-in default examples however.

## Docker image

A Docker image is automatically built by Travis CI and pushed to the repository
at https://hub.docker.com/r/dlangtour/core. The Dlang-Tour Docker container
is configured to use Docker itself to compile and run D source code
in the online editor. For that to work the host system's Docker `/var/run/docker.sock`
Unix domain socket has to be mounted to work inside the container. A
**sandbox** for compiling will then be started on the host system actually,
and not within the DLang Tour Docker container itself.

The code for running the D compilers in a Docker sandbox can be found here:
[core-exec](https://github.com/dlang-tour/core-exec).

So to run the latest dlang-tour
version in a Docker container, run the following command:

	docker run -d --rm -p 80:8080 -e GOOGLE_ANALYTICS_ID=123 -v /var/run/docker.sock:/var/run/docker.sock \
		--name dlang-tour dlangtour/core

The tour will be available at your host system on port 80. To stop the container
again just run:

	docker stop dlang-tour

For further Docker foo please refer to the Docker documentation.

**Note:** The docker version inside the container must be compatible
to that on the host system! Generally a newer version might run
on the host system than within the container.

The Docker container is also the suggested way
of [dlang-tour's deployment](deploy/README.md).

## Dlang Tour Bot

There is a friendly bot in place that listens to the events of all language repositories and triggers rebuilds and thus automatic deploments on a new change.
More information about it can be found at it's [repository](https://github.com/dlang-tour/bot).

### Environment variables

#### `GOOGLE_ANALYTICS_ID`

> default: (empty)

To enable **Google Analytics** please specify the environment variable
`GOOGLE_ANALYTICS_ID` and set it to the tracking ID provided
for your Analytics account.

#### `GITHUB_TOKEN`

> default: (empty)

Required for exporting Gists to GitHub.
Follow [these instrutions](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line) to generate a CLI GitHub token.

#### `EXEC_DOCKER_MEMORY_LIMIT`

> default: 256

Memory limit per started `rdmd` Docker container which compiles
and runs the user code.

#### `EXEC_DOCKER_MAX_QUEUE_SIZE`

> default: 10

Maximum number of parallel executions of the `rdmd` user code
Docker container.

#### `EXEC_DOCKER_TIME_LIMIT`

> default: 20

Time limit in seconds the `rdmd` Docker container with the user
code is allowed to take until it is killed.

#### `EXEC_DOCKER_MAX_OUTPUT_SIZE`

> default: 4096

Maximum allowed size in bytes of the generated user program's output.

## Deployment

A deployment guide can be found in the [deploy](deploy/README.md)
folder.

## License

Boost License. See [LICENSE.txt](LICENSE.txt) for more details.

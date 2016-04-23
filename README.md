# The Dlang Online Tour

[![Build Status](https://travis-ci.org/stonemaster/dlang-tour.svg?branch=master)](https://travis-ci.org/stonemaster/dlang-tour)

This is the [D language](https://dlang.org) online tour which
provides an online introduction to this great system programming language
with examples that can be edited, compiled and run online.

The current state of this tour can be seen here: http://tour.dlang.io.

## Add Content

Please refer to the document [public/content/README.md](public/content/README.md)
for further information on how to add or change existing content.

## Compile & Run

Make sure [dub](http://code.dlang.org/download) is installed and simply run this in
the `dlang-tour` folder:

	dub

You might want to change the settings in `config.yml` to change
the ports the tour is listening to.

## Compiling & running of user source code

The source code on the tour can be compiled and then executed online and its output returned
to the user. Therefore three different types of **execution drivers** have been
implemented within the dlang-tour:

 * `off`: no online compilation allowed. If the user hits ***Runs*** an error message
   will be returned.
 * `stupidlocal`: an unsafe method that just runs `rdmd` on the local host system
   and returns its output. ***Very unsafe*** and musn't ever be used in production!
 * `docker`: runs `rdmd` within a special Docker container ([dlang-tour-rdmd](https://github.com/stonemaster/dlang-tour-rdmd))
   and returns its output. The driver imposes the Docker container memory and 
   execution time limits. Additional configurations options available in `config.yml`.

The execution driver is set in `config.yml`.

Caching of the program output can also be enabled in `config.yml` (`exec.cache = true`). Caching
will only be enabled for the built-in default examples however.

## Docker image

A Docker image is automatically built by Travis CI and pushed to the repository
at https://hub.docker.com/r/stonemaster/dlang-tour/. The Dlang-Tour Docker container
is configured to use Docker itself to compile and run D source code
in the online editor. For that to work the host system's Docker `/var/run/docker.sock`
Unix domain socket has to be mounted to work inside the container. Any
**sandbox** for compiling will then be started on the host system actually,
and not within the Dlang Tour Docker container itself.

The code for running RDMD in a Docker sandbox can be found here:
[dlang-tour-rdmd](https://github.com/stonemaster/dlang-tour-rdmd).

So to run the latest dlang-tour
version in a Docker container, run the following command:

	docker run -d --rm -p 80:8080 -e GOOGLE_ANALYTICS_ID=123 -v /var/run/docker.sock:/var/run/docker.sock \
		--name dlang-tour stonemaster/dlang-tour

The tour will be available at your host system on port 80. To stop the container
again just run:

	docker stop dlang-tour

For further Docker foo please refer to the Docker documentation.

**Note:** The docker version inside the container must be compatible
to that on the host system! Generally a newer version might run
on the host system than within the container.

### Environment variables

#### `GOOGLE_ANALYTICS_ID`

> default: (empty)

To enable **Google Analytics** please specify the environment variable
`GOOGLE_ANALYTICS_ID` and set it to the tracking ID provided
for your Analytics account.

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

## Systemd Unit

A systemd unit has been included with [dlang-tour.service](deploy/dlang-tour.service)
which allows to quickly install a service for systemd
enabled distributions like newer Debian/Ubuntu's and CoreOS. Just
install this service file and run `systemctl start dlang-tour` to
run the dlang-tour using Docker (which is a pre-requisite of course).

## License

Boost License. See [LICENSE.txt](LICENSE.txt) for more details.

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

To enable **Google Analytics** please specify the environment variable
`GOOGLE_ANALYTICS_ID` and set it to the tracking ID provided
for your Analytics account.

## Systemd Unit

A systemd unit has been included at [dlang-tour.service](dlang-tour.service)
which allows to quickly install a service for systemd
enabled distributions like newer Debian/Ubuntu's and CoreOS. Just
install this service file and run `systemctl start dlang-tour` to
run the dlang-tour using Docker (which is a pre-requisite of course).

## License

Boost License. See [LICENSE.txt](LICENSE.txt) for more details.

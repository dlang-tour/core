# The Dlang Online Tour

This is the [D language](https://dlang.org) online tour which
provides an online introduction to this great system programming language
with examples that can be edited, compiled and run online.

**This Tour is heavy work-in-progress.**

## Add Content

Please refer to the document [public/content/README.md](public/content/README.md)
for further information on who to add or change existing content.

## Compile & Run

Make sure [dub](http://code.dlang.org/download) is installed and simply run this in
the `dlang-tour` folder:

	dub

You might want to change the settings in `config.yml` to change
the ports the tour is listening to.

## Docker image

A Docker image is automatically built by Travis CI and pushed to the repository
at https://hub.docker.com/r/stonemaster/dlang-tour/. So to run the latest dlang-tour
version in a Docker container, run the following command:

	docker run -d --rm -p 80:8080 --name dlang-tour stonemaster/dlang-tour

The tour will be available at your host system on port 80. To stop the container
again just run:
	
	docker stop dlang-tour

For further Docker foo please refer to the Docker documentation.

## License

Boost License. See [LICENSE.txt](LICENSE.txt) for more details.

# Vibe.d web framework

[Vibe.d](http://vibed.org) is a very powerful web
framework which this tour for example has been written
with. Here are some highlights of vibe.d:

* Based on a fiber based approach for *asynchronous I/O*
  vibe.d allows to write high-performance HTTP(S) web servers
  and web services. Write code which looks synchronous
  but actually does the ugly asynchronous handling
  of thousands of connections in the background
  for you! See the next section for a thorough
  example.
* An easy to use JSON and web interface generator
* Out-of-the-box
  support for Redis and MongoDB make it easy to
  write backend systems that have a good performance
* Generic TCP or UDP clients and servers can be
  written as well using this framework

Note that the examples in this chapter
can't be run online because they
would require network support which is disabled
for obvious security reasons.

The easiest way to create a vibe.d project is to install
`dub` and create a new project with *vibe.d* specified
as template:

    dub init <project-name> -t vibe.d

`dub` will make sure that vibe.d is downloaded and
available for building your vibe.d based project.

The book [D Web development](https://www.packtpub.com/web-development/d-web-development)
gives a thorough introduction into this great
framework.


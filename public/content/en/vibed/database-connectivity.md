# Database connectivity

Vibe.d makes it easy to access databases
in your backend services. **MongoDB** and **Redis**
support come directly with vibe.d, other database
adaptors can be found on [code.dlang.org](https://code.dlang.org).

### MongoDB

Access to MongoDB is modelled around the class
[`MongoClient`](http://vibed.org/api/vibe.db.mongo.client/MongoClient).
The implementation doesn't have external dependencies
and is implemented using vibe.d's asynchronous
sockets - no need to block if the connection
has some latency.

    auto client = connectMongoDB("127.0.0.1");
    auto users = client.getCollection("users");
    users.insert(Bson("peter"));

### Redis

Redis support is implemented with vibe.d sockets as well
and doesn't have external dependencies. Central
to the implementation is the
[`RedisDatabase`](http://vibed.org/api/vibe.db.redis.redis/RedisDatabase)
class which allows to run commands against a Redis
server. There are also convenience wrappers available, like
[`RedisList`](http://vibed.org/api/vibe.db.redis.types/RedisList)
which allows to transparently access a list
stored in Redis.

### MySQL

MySQL support without external dependencies
to the official MySQL library can be
added using the
[mysql-native](http://code.dlang.org/packages/mysql-native)
project. It supports vibe.d non-blocking sockets
too.

### Postgresql

A full-featured Postgresql client is implemented
with the external module [dpq2](http://code.dlang.org/packages/dpq2)
that is based on the official *libpq* library.
It uses vibe.d's event system to implement
asynchronous behaviour.

Another alternative for Postgresql is
[ddb](http://code.dlang.org/packages/ddb)
which implements a Postgresql client with
vibe.d sockets and no external dependencies.



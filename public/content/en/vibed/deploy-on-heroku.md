# Deploy on Heroku

### Pre-requirements

- Heroku [account]((https://signup.heroku.com/login))
- [Git](https://git-scm.com/) installed
- Your application should compile without error using dmd (`dub build`).

### 1 : Setup the app

Heroku needs to know how to communicate with a deployed application.
Hence a global `PORT` environment variable is provided which needs to be injected into an application and
it should bind and listen to this port.
For development a default port (here __8080__) should be set:

```d
shared static this() {
  // ...
  auto settings = new HTTPServerSettings;
  // Provide a default port in case of the $PORT variable isn't set.
  settings.port = environment.get("PORT", "8080").to!ushort;
  listenHTTP(settings, router);
}
```

Additionally create a `Procfile`, which is a text file in the root directory of the application, which explicitly declares what command
should be executed to start the app.

The `Procfile` in the example app looks like this:

```
web: ./hello-world
```

### 2 : Prepare the app

Before going further login to the Heroku Command Line by using the [Heroku Toolbelt](https://toolbelt.heroku.com/standalone).

This provides access to the Heroku Command-Line Interface (CLI), which can be used for managing and scaling your applications and add-ons.

After installing the toolbet run the following:

```
$ heroku login
```

### 3 : Create the app

Go to the [heroku dashboard](https://dashboard.heroku.com) and create a new app.
After doing this memorize the name of the created app, it will be useful later.

Or use the Command-Line like this:

```
$ heroku create
Creating app... done, ⬢ rocky-hamlet-67506
https://rocky-hamlet-67506.herokuapp.com/ | https://git.heroku.com/rocky-hamlet-67506.git
```

The app's name here is *rocky-hamlet-67506*.

### Deploy using git

To deploy the app directly use `git` commands. A separate git remote endpoint should be added to which new releases can be pushed.
Thus the name of the newly created application
in the previous chapter needs to be passed as argument - here it is *rocky-hamlet-67506*.

```
$ heroku git:remote -a rocky-hamlet-67506
```

Notice the remote endpoint is added to the git config:

```
$ git remote -v
heroku	https://git.heroku.com/rocky-hamlet-67506.git (fetch)
heroku	https://git.heroku.com/rocky-hamlet-67506.git (push)
```

### Adding the buildpack

Buildpacks are responsible for generating assets or compiled code.

For more information browse the [Heroku documentation](https://devcenter.heroku.com/articles/buildpacks)

For deployement the [Vibe.d buildpack](https://github.com/MartinNowak/heroku-buildpack-d) can be used:

```
$ heroku buildpacks:set https://github.com/MartinNowak/heroku-buildpack-d
```
By default the buildpack uses the latest `dmd` compiler.
It is possible to use GDC or LDC and to choose a specific compiler versions by adding a `.d-compiler` file to your project.

Use `dmd`, `ldc`, or `gdc` to select the latest or `dmd-2.0xxx`, `ldc-1.0xxx`, or `gdc-4.9xxx` to
select a specific version of a compiler.

### Deploy the code

Proceed in your usual git habit and write awesome code.

To release a new version, just push the newest version to the Heroku endpoint.

```
$ git add .
$ git commit -am "My first vibe.d release"
$ git push heroku master
Counting objects: 9, done.
Delta compression using up to 2 threads.
Compressing objects: 100% (6/6), done.
Writing objects: 100% (9/9), 997 bytes, done.
Total 9 (delta 0), reused 0 (delta 0)

-----> Fetching custom git buildpack... done
-----> D (dub package manager) app detected
-----> Building libevent
-----> Building libev
-----> Downloading DMD
-----> Downloading dub package manager
-----> Setting PATH:
-----> Initializing toolchain
-----> Building app
       Running dub build ...
Building configuration "application", build type release
Running dmd (compile)...
Compiling diet template 'index.dt' (compat)...
Linking...
       Build was successful
-----> Discovering process types
       Procfile declares types -> web
-----> Compiled slug size: 3.5MB
-----> Launching... done, v4
       https://rocky-hamlet-67506.herokuapp.com/ deployed to Heroku
To git@heroku.com:rocky-hamlet-67506.git
 * [new branch]      master -> master
```

Open the app in the browser with the following command

```
$ heroku open
```

### Scaling dynos containers

After deploying, the app is running on a web dyno.
Think of a dyno as a lightweight container that runs the command specified in the Procfile.

Using the `ps` command allows checking how many dynos are running:

```
$ heroku ps
Free dyno hours quota remaining this month: 550h 0m (100%)
For more information on dyno sleeping and how to upgrade, see:
https://devcenter.heroku.com/articles/dyno-sleeping

No dynos on ⬢ rocky-hamlet-67506
```

By default, the app is deployed on a free dyno which doesn't accept requests by default.
Free dynos will sleep after a half hour of inactivity. This causes a delay of a few seconds for the first request upon waking.

To start the dyno run the following:

```
$ heroku ps:scale web=1
```

### See the logs

Heroku treats logs as streams of time-ordered events aggregated from the output streams of all your app and Heroku components,
providing a single channel for all of the events.

```
$ heroku logs --tail
```

## More informations

After deploying the app to Heroku you can make it more awesome by using add-ons. For example :

- [Postgresql](https://elements.heroku.com/addons/heroku-postgresql)
- [MongoDb](https://elements.heroku.com/addons/mongohq)
- [Logging](https://elements.heroku.com/addons#logging)
- [Caching](https://elements.heroku.com/addons#caching)
- [Error and exceptions](https://elements.heroku.com/addons#errors-exceptions)

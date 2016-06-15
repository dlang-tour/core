# Deploy on Heroku

### Pre-requirements

- You must have an [account]((https://signup.heroku.com/login)) on heroku
- You should have [git](https://git-scm.com/) installed
- Your application should compile without error using dmd (`dub build --build=release`). 


### 1 : Setup the app

The first thing we need to do before deploying our app to the cloud is binding our app's port to heroku's one. 
Heroku sets the `PORT` variable that you are supposed to bind, and listens on tcp/80.

```d
shared static this() {
  // ...
  auto settings = new HTTPServerSettings;
  // Provide a default port in case of the $PORT variable isn't set.  
  settings.port = environment.get("PORT", "8080").to!ushort;
  listenHTTP(settings, router);
}
```

You also need to create a `Procfile`, which is a text file in the root directory of your application, in which you explicitly declare what command 
should be executed to start your app.

The Procfile in the example app looks like this:

```
web: ./hello-world
```

### 2 : Prepare the app 

Before going further you should login to the heroku cli.

To login you have to use the [heroku toolbelt](https://toolbelt.heroku.com/standalone).

This provides you access to the Heroku Command Line Interface (CLI), which can be used for managing and scaling your applications and add-ons.

After installing the toolbet just run 

```
$ heroku login
```

### 3 : Create the app 

To do so you can go on the [heroku dashboard](https://dashboard.heroku.com) and create a new app. 
After doing so memorize the name of your app, you will use it later. 



or use the command line like this 

```
$ heroku create
Creating app... done, ⬢ rocky-hamlet-67506
https://rocky-hamlet-67506.herokuapp.com/ | https://git.heroku.com/rocky-hamlet-67506.git
```

The app's name here is rocky-hamlet-67506. 

### Deploy using git 


You can deploy your app directly from `git` - it will be in a separate git remote endpoint to which new releases can be pushed.

You need to add the git remote with the name of your app. 
As shown in the previous section, our name's app is rocky-hamlet-67506. But change it to yours. 

```
$ heroku git:remote -a rocky-hamlet-67506
```

You can see now that the remote endpoint is added to our git config

```
$ git remote -v
heroku	https://git.heroku.com/rocky-hamlet-67506.git (fetch)
heroku	https://git.heroku.com/rocky-hamlet-67506.git (push)
```

### Adding the buildpack

Buildpacks are responsible for transforming deployed code into a slug, 
which can then be executed on a dyno. Buildpacks are composed of a set of scripts, 
and depending on the programming language, the scripts will retrieve dependencies, 
output generated assets or compiled code, and more.

For more information you can browse the [Heroku documentation](https://devcenter.heroku.com/articles/buildpacks)

We are going to use this [webpack](https://github.com/skirino/heroku-buildpack-vibe.d), the heroku-buildpack-vibe.d that uses dmd by default. 

```
$ heroku buildpacks:set https://github.com/skirino/heroku-buildpack-vibe.d.git#cedar-14
```

You should also create a file called `vibed_buildpack.config` in the root of your app. 
We are doing this because this buildpack's dependencies are outdated. 

Fortunately we can override them by providing new urls : 

```
DMD_ARCHIVE_URL = http://downloads.dlang.org/releases/2016/dmd.2.071.2.zip
DUB_ARCHIVE_URL = http://code.dlang.org/files/dub-0.9.25-linux-x86_64.tar.gz
```

### Deploy the code 

You can proceed in your usual git habit and write awesome code. 

Once you want to release a new version, you just push the newest version to the heroku endpoint.

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

All you need to do now is open the app in the browser.

```
$ heroku open
```

### Openning dynos to request 

Right now, our app is running on a web dyno. Think of a dyno as a lightweight container that runs the command specified in the Procfile.

You can check how many dynos are running using the ps command:

```
$ heroku ps
Free dyno hours quota remaining this month: 550h 0m (100%)
For more information on dyno sleeping and how to upgrade, see:
https://devcenter.heroku.com/articles/dyno-sleeping

No dynos on ⬢ rocky-hamlet-67506
```

By default, your app is deployed on a free dyno which can't access request. 
Free dynos will sleep after a half hour of inactivity (if they don’t receive any traffic). This causes a delay of a few seconds for the first request upon waking. 

To make it work you should open it up using 

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

After deploying your app to Heroku you can make it more awesome by using add-ons.

- [Postgresql](https://elements.heroku.com/addons/heroku-postgresql)
- [MongoDb](https://elements.heroku.com/addons/mongohq)
- [Logging](https://elements.heroku.com/addons#logging)
- [Caching](https://elements.heroku.com/addons#caching)
- [Error and exceptions](https://elements.heroku.com/addons#errors-exceptions)

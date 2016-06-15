# Deploy Vibe.d on production


To deploy Vibe.d application you have several choices. If you have access to your own machine you could directly 
upload the source code on the machine, compile the code and run it. 

But the are few other solutions that are more interesting. 


## Using Heroku


The most basic solution is to deploy using Heroku on a free dyno. 


### Requirements

- You must have an account on heroku 
- You should have git installed
- Your application should using `dub build --build=release`


### 1 : Setup the app

The first thing we need to do before sending our little app to the cloud is bind our app's port to heroku's one. 
Indeed, heroku will "dynamically" setup a port for the dyno to listen to. Our app should have the same to be able to handle requests. 

In the app.d 

```d
shared static this() {
  // ...
  auto settings = new HTTPServerSettings;
  // Provide a default port in case of the $PORT variable isn't set.  
  settings.port = environment.get("PORT", "8080").to!ushort;
  listenHTTP(settings, router);
}
```

You also need to create a Procfile, which is a text file in the root directory of your application, responsible to explicitly declare what command 
should be executed to start your app.

The Procfile in the example app you deployed looks like this:

```
web: ./my-app
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

To deploy your app you will use git and push your code to heroku as if you were pushing on your git repo. 

You need to add the git remote with the name of your app. 

As shown in the previous section, our name's app is rocky-hamlet-67506. But change it to yours. 

```
$ heroku git:remote -a rocky-hamlet-67506
```

### Adding the buildpack

Buildpacks are responsible for transforming deployed code into a slug, 
which can then be executed on a dyno. Buildpacks are composed of a set of scripts, 
and depending on the programming language, the scripts will retrieve dependencies, 
output generated assets or compiled code, and more.

[More information](https://devcenter.heroku.com/articles/buildpacks)

We are going to use this [webpack](https://github.com/skirino/heroku-buildpack-vibe.d) it uses dmd by default. 

```
$ heroku buildpacks:set https://github.com/skirino/heroku-buildpack-vibe.d.git#cedar-14
```

You should also create a file called `vibed_buildpack.config` in the root of your app :

```
DMD_ARCHIVE_URL = http://downloads.dlang.org/releases/2016/dmd.2.070.2.zip
DUB_ARCHIVE_URL = http://code.dlang.org/files/dub-0.9.25-linux-x86_64.tar.gz
```

We are doing this because the buildpack dependencies are outdated. 
Fortunately you can override them by providing a new url using this file.

### Deploy the code 

```
$ git add .
$ git commit -am "make it better"
$ git push heroku master
```

Now the buildpack will take the hand and compile our app and launch it using the Procfile. 

### Scale the app 

Right now, our app is running on a single web dyno. Think of a dyno as a lightweight container that runs the command specified in the Procfile.
You can check how many dynos are running using the ps command:

```
$ heroku ps
Free dyno hours quota remaining this month: 550h 0m (100%)
For more information on dyno sleeping and how to upgrade, see:
https://devcenter.heroku.com/articles/dyno-sleeping

No dynos on ⬢ rocky-hamlet-67506
```

By default, your app is deployed on a free dyno. 
Free dynos will sleep after a half hour of inactivity (if they don’t receive any traffic). This causes a delay of a few seconds for the first request upon waking. 

To make it work you should scale it up using 

```
$ heroku ps:scale web=1
```
 
### See the logs 

Heroku treats logs as streams of time-ordered events aggregated from the output streams of all your app and Heroku components, 
providing a single channel for all of the events.

```
$ heroku logs --tail
```


## Using docker

# Airbrake Hapi #
A Hapi Plugin that automatically sends internal server errors to [Airbrake.io](https://airbrake.io/).

## Compatibility ##
Version 1.0.0 -> Hapi 8.x

## Usage ##

To use this plugin you need an Airbrake account. Login and navigate to your project, and get your API key:

![dashboard](http://cl.ly/image/1T1A0J0s201X/airbrake_dashboard.png)

You will also need your project ID, which can be found in the URL of your project:

`https://yyyyyyy.airbrake.io/projects/XXXXXX`
(The X's)

Once you have those two pieces of data, you can go ahead and get started:

`npm install airbrake-hapi --save`

Then:

```js
var Hapi = require('hapi');
var server = new Hapi.Server();
server.connection({ host: 'localhost' });

var options = {
	id: 'airbrake_id_here',
    key: 'airbrake_api_key_here',
    notifierURL: 'url_for_application',	
    name: 'application name',
    version: '1.x'
};

server.register({
    register: require('airbrake-hapi'),
    options: options
}, function (err) {
    if (err) {
        console.error(err);
    } else {
        server.start(function () {
            console.info('Server started at ' + server.info.uri);
        });
    }
});
```

Required Options:
* `id` - The Project ID from Airbrake
* `key` - The Project API Key

Optional:
* `notifierURL` - A URL to tell Airbrake what this project is.
* `name` - The Application Name
* `version` - The current application version. Airbrake Hapi will automatically try and set this to the current Git Hash, if you are using Git. It runs `git rev-parse HEAD` (run it yourself to see what it returns).


### Events ###
On the plugin is registered, you can listen for events to let you know when an error has been sent to Airbrake. You first need to get the plugin reference, and then you can add your event listener for success `sent`

```js
airbrake = server.plugins['airbrake-hapi'].airbrake
airbrake.on('sent', function(event) {
	console.log('Sent to Airbrake!', event)
	/*
	Prints:
	{id: '323423094820', url: 'https://airbrake.io/locate/323423094820'}
	*/
});
```

In the case of an error, you can also listen for `error`:
```js
airbrake = server.plugins['airbrake-hapi'].airbrake
airbrake.on('error', function(err) {
	console.log(Error sending to Airbrake!', err)
});
```

This does not track deploys, but maybe it could.

## Development ##
Airbrake Hapi is written in [CoffeeScript](http://coffeescript.org/), because I enjoy the easier to use syntax over pure javascript. However, the project is compiled to Javascript on prepublish:

`"prepublish":"coffee -o bin -c lib/*.coffee"`

You can use this project for any Node project, but development needs to be in CoffeeScript.

Airbrake Hapi uses the [Notifier v3](https://help.airbrake.io/kb/api-2/notifier-api-v3) to send issues to Airbrake. The v3 API accepts JSON, which makes the code much simpler and easier.

The bulk of the code is in `/lib/airbrake.coffee`, which is the class that handles the error parsing and sending of the requests.

`/lib/index.coffee` is used to stage the Hapi Plugin, which enables simple setup.

### Tests ###
There are tests located in `test`. These are broken into unit and integration test. These tests can be run easily with `make`. If you contribute, please make sure to add a test and ensure all tests pass. Of course, to run the integration tests, you will have to have your own `id` and `key` for Airbrake.

If you don't, but really think your tests should pass, send a pull request, and I'll run it with my own credentials.

### Code Coverage ###
Running `make cov` will run the code coverage. Ensure all tests pass first. This will instrument and open a window showing the result. Since this is such a small project, code coverage is 100%. Let's keep it that way.

### Contributing ###
Send a pull request or open an issue! This is being used in production and fitted towards my needs, but can easily be expanded.

# Changelog #

### Version 1.0.0 ###
* Initial Release

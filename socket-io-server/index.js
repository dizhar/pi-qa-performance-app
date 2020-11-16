// Setup basic express server
var express = require('express');
var app = express();
var server = require('http').createServer(app);
var io = require('socket.io')(server);
var redis = require('socket.io-redis');
var shell = require('shelljs');

var port = process.env.PORT || 3000;
var serverName = process.env.NAME || 'Unknown';

// esm
const { docker } = require('docker-cli-js');

// https://github.com/Quobject/docker-cli-js
var dockerCLI = require('docker-cli-js');
var DockerOptions = dockerCLI.Options;
var Docker = dockerCLI.Docker;

io.adapter(redis({ host: 'redis', port: 6379 }));

server.listen(port, function () {
	console.log('Server listening at port %d', port);
	console.log('Hello, I\'m %s, how can I help?', serverName);
});

// Routing
app.use(express.static(__dirname + '/public'));

// Chatroom

var numUsers = 0;

io.on('connection', function (socket) {

	// https://stackoverflow.com/questions/43086991/socket-io-emit-in-loop-until-client-responds
	const interval = 5000;
	// loop(socket)
	console.log(socket.id + ' has connected');

	// default options
	// const options = {
	// 	machineName: null, // uses local docker
	// 	currentWorkingDirectory: null, // uses current working directory
	// 	echo: true, // echo command output to stdout/stderr
	// };
	var options = new DockerOptions(null, null, true);
	var docker = new Docker(options);

	var foo = setInterval (function () {
			// socket.emit('foo');

			// var script = "docker ps | grep pi-qa-sitespeed | awk '{print $1}'"
			var script = "docker ps --filter name='pi-qa-sitespeed-' --format '{{json .}}' | jq -s '[.[] | {id:.ID, name:.Names}]'"
			// var stdout= shell.exec(`${script}`, { silent: false }).stdout;
			var json = shell.exec(script).stdout;
			console.log(json);

			var json_obj = JSON.parse(json)

			json_obj.forEach((item) => {
				script = "docker ps --filter name='pi-qa-sitespeed-' --format '{{json .}}' | jq -s '[.[] | {id:.ID, name:.Names}]'"
				
				json = shell.exec(script).stdout;
				json_obj = JSON.parse(json)

				console.log('Broadcasting info of container ' + + item.name)
				msg_data = {
					username: socket.username,
					message: 'NAME: ' + item.name
				}
				socket.broadcast.emit('new message', msg_data);
			});

			// var docker_data = await dockerCommand('ps', options);
			// console.log(docker_data);
			// var command = 'logs nginx-reverse-proxy'
			
			// var command = 'logs backend'
			// docker.command(command).then(function (data) {
			// 	console.log('data = ', data);

			// 	msg_data = {
			// 		username: socket.username,
			// 		// message: data.containerList[0].names
			// 		message: data.raw
			// 	}
			// 	// socket.emit('my-name-is', 'TSADOK LEVI');
			// 	socket.broadcast.emit('new message', msg_data);
			//   });

			
	}, interval);   
	socket.on('confirmed', function () {
			console.log('confirmation received from ' + socket.id);
			clearInterval(foo);
	});   

	socket.emit('my-name-is', serverName);

	var addedUser = false;

	// when the client emits 'new message', this listens and executes
	socket.on('new message', function (data) {
		// we tell the client to execute 'new message'
		socket.broadcast.emit('new message', {
			username: socket.username,
			message: data
		});
	});

	// when the client emits 'add user', this listens and executes
	socket.on('add user', function (username) {
		if (addedUser) return;

		// we store the username in the socket session for this client
		socket.username = username;
		++numUsers;
		addedUser = true;
		socket.emit('login', {
			numUsers: numUsers
		});
		// echo globally (all clients) that a person has connected
		socket.broadcast.emit('user joined', {
			username: socket.username,
			numUsers: numUsers
		});
	});

	// when the client emits 'typing', we broadcast it to others
	socket.on('typing', function () {
		socket.broadcast.emit('typing', {
			username: socket.username
		});
	});

	// when the client emits 'stop typing', we broadcast it to others
	socket.on('stop typing', function () {
		socket.broadcast.emit('stop typing', {
			username: socket.username
		});
	});

	// when the user disconnects.. perform this
	socket.on('disconnect', function () {
		if (addedUser) {
			--numUsers;

			// echo globally that this client has left
			socket.broadcast.emit('user left', {
				username: socket.username,
				numUsers: numUsers
			});
		}


		
		


	});
});
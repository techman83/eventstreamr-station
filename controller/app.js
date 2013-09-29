
/**
 * Module dependencies.
 */

var express = require('express');
var routes = require('./routes');
var http = require('http');
var path = require('path');

var app = express();

// all environments
app.set('port', process.env.PORT || 3000);
app.set('views', __dirname + '/views');
app.set('view engine', 'jade');
app.use(express.favicon());
app.use(express.logger('dev'));
app.use(express.bodyParser());
app.use(express.methodOverride());
app.use(app.router);
app.use(express.static(path.join(__dirname, 'public')));

// development only
if ('development' == app.get('env')) {
  app.use(express.errorHandler());
}

app.get('/', routes.index);

http.createServer(app).listen(app.get('port'), function(){
  console.log('Express server listening on port ' + app.get('port'));
});/**
 * Module dependencies.
 */

var express = require('express');
var http = require('http');
var request = require('request');
var getmac =  require('getmac').getMac;
var fs = require('fs');

// station data
var station = {};

var app = express();

// all environments
app.set('port', 5001);
app.use(express.logger('dev'));
app.use(express.bodyParser());
app.use(express.methodOverride());
app.use(app.router);

// development only
if ('development' == app.get('env')) {
  app.use(express.errorHandler());
}

app.get('/station/:id', function(req, res) {
  res.send('success')
});

http.createServer(app).listen(app.get('port'), function(){
  console.log('Eventstreamr controller listening on port ' + app.get('port'));
});

request('controller.eventstreamr:5001/config/'+ station.id, function (error, response, body) {
  if (!error && response.statusCode == 200) {
  }
  else {
  }
})

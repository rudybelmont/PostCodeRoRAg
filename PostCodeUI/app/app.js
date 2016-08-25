
  'use strict';

// Declare app level module which depends on views, and components
var app = angular.module('myApp', [
  'ngRoute',  
  'myApp.version',

   //app
  'myApp.config',
  
  //services
  'myApp.suburbs.service',
  'myApp.postcode.service',
  
  'myApp.dashboard',
  'myApp.view2'
])

app.config(function($locationProvider, $routeProvider) {
  $locationProvider.hashPrefix('!');

  $routeProvider.otherwise({redirectTo: '/dashboard'});
});

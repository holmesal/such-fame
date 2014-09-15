'use strict'

angular.module('portfolioApp', [
  'ngCookies',
  'ngResource',
  'ngSanitize',
  'ngRoute',
  'famous.angular'
])
  .config ($routeProvider) ->
    $routeProvider
      .when '/',
        templateUrl: 'views/main.html'
        controller: 'MainCtrl'
      .otherwise
        redirectTo: '/'

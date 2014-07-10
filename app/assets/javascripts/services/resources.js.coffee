angular.module('portfolio.resources', ['ngResource']).
  factory('Quotes', ['$resource', ($resource) ->
    $resource "/quotes", {format: 'json'}
  ]).
  factory('Preferences', ['$resource', ($resource) ->
    $resource "/preferences", {format: 'json'}
  ])

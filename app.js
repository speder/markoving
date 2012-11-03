angular.module('Random', ['ngResource']);

function RandomController($scope, $resource) {
  var resource = $resource('http://localhost:port',
      {port: ':3000', callback: 'JSON_CALLBACK'},
      {get: {method: 'JSONP'}});

  $scope.randomize = function () {
    var options = {chunk: $scope.chunk};

    if ($scope.url) options.url = $scope.url;
    if ($scope.refresh) options.refresh = true;

    $scope.refresh = false;
    $scope.json = '';

    resource.get(options, function(response) {
      if ($scope.debug) $scope.json = response;
      $scope.random = response.chunk;
    });
  };

  $scope.chunks = ['word', 'sentence', 'paragraph', 'paragraphs'];
  $scope.chunk = $scope.chunks[1];
}

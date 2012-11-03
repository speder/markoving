angular.module('Random', ['ngResource']);

function RandomController($scope, $resource) {
  var resource = $resource('http://localhost:port',
      {port: ':3000', callback: 'JSON_CALLBACK'},
      {get: {method: 'JSONP'}});

  $scope.randomize = function () {
    var options = {chunk: $scope.chunk};

    if ($scope.refresh) {
      options.refresh = true;
      if ($scope.canned) {
        options.canned = $scope.canned;
      } else if ($scope.text) {
        options.text = $scope.text;
      } else if ($scope.url) {
        options.url = $scope.url;
      }
    }

    $scope.refresh = false;
    $scope.json = '';

    resource.get(options, function(response) {
      if ($scope.debug) $scope.json = response;
      $scope.random = response.chunk;
    });
  };

  $scope.cannedData = ['', 'carroll', 'dickens', 'dostoevsky', 'freud', 'joyce', 'kafka', 'marx', 'proust', 'shakespeare'];
  $scope.canned = $scope.cannedData[0];

  $scope.chunks = ['word', 'sentence', 'paragraph', 'paragraphs'];
  $scope.chunk = $scope.chunks[1];
}

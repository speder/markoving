angular.module('Random', ['ngResource']);

function RandomController($scope, $resource) {
  var resource = $resource('http://localhost:port',
      {port: ':3000', callback: 'JSON_CALLBACK'},
      {get: {method: 'JSONP'}});

  $scope.randomize = function() {
    var options = {chunk: $scope.chunk};

    if ($scope.source) {
      options.source = true;
      if ($scope.text) {
        options.text = $scope.text;
      } else if ($scope.paste) {
        options.paste = $scope.paste;
      } else if ($scope.url) {
        options.url = $scope.url;
      }
    };

    $scope.source = false;
    $scope.random = '';
    $scope.json = '';

    resource.get(options, function(response) {
      if ($scope.debug) $scope.json = response;
      $scope.random = response.chunk;
    });
  };

  $scope.sourceType = function(source) {
    return $scope.init === source;
  }
  
  $scope.texts = ['', 'apuleius', 'bible', 'burton', 'carroll', 'darwin', 'dickens', 'dostoevsky', 'fielding', 'freud', 'frazer', 'goethe', 'hobbes', 'homer', 'johnson', 'joyce', 'kafka', 'kamasutra', 'kipling', 'koran', 'lawrence', 'marx', 'machiavelli', 'melville', 'nietzsche', 'petronius', 'proust', 'shakespeare', 'swift', 'tao', 'tolstoy', 'twain', 'voltaire', 'whitman', 'wilde', 'yogananda'];
  $scope.text = $scope.texts[0];
  
  $scope.inits = ['', 'text', 'paste', 'url'];
  $scope.init = $scope.inits[0];
  
  $scope.chunks = ['word', 'sentence', 'paragraph', 'paragraphs'];
  $scope.chunk = $scope.chunks[2];
  
}

require ::File.expand_path('../rb/app',  __FILE__)

use Rack::Static, :urls => ['/css/', '/favicon.ico', '/js/']

map '/json' do
  run MarkovApp.new
end

map '/' do
  run lambda { |env|
    [200, {'Content-Type' => 'text/html',}, File.open('html/index.html', File::RDONLY)]
  }
end


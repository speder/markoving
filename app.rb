require 'json'
require 'literate_randomizer'
require 'open-uri'
require 'nokogiri'
require 'rack'
require 'rack/server'
require 'thin'

class RandomApp
  METHODS = %w(word sentence paragraph paragraphs)
  URL = 'http://ia700305.us.archive.org/7/items/alicesadventures19002gut/19002-h/19002-h.htm'

  def self.create_randomizer(options = {})
    if options['url']
      html = open(options['url'])
      source_material = Nokogiri::HTML(html).text
      LiterateRandomizer.create(:source_material => source_material)
    elsif options['shakes']
      LiterateRandomizer.create(:source_material => File.read('shakes.txt'))
    else # poe!
      LiterateRandomizer.create
    end
  end

  def self.randomizer(options = {})
    @@randomizer = nil if options['refresh']
    @@randomizer ||= create_randomizer(options)
  end

  def self.text(options = {})
    method = METHODS.include?(options['chunk']) ? options['chunk'] : METHODS.first
    randomizer(options).send(method)
  end

  def self.call(env)
    req = Rack::Request.new(env)

    data = text(req.params)

    if req.params['callback'] or req.params['json']
      data = JSON.dump({ :chunk => data })
    end

    if req.params['callback']
      data = "#{req.params['callback']}(#{data})"
    end

    #res = Rack::Response.new
    #res.status = 200
    #res['Content-type'] = 'application/javascript; charset=utf-8'
    #res.body = data.respond_to?(:each) ? data : [data]
    #res.finish
    [200, {'Content-type' => 'application/javascript; charset=utf-8'}, data.respond_to?(:each) ? data : [data]]
  end
end

Rack::Server.start :app => RandomApp, :Port => 3000

require 'json'
require 'literate_randomizer'
require 'open-uri'
require 'nokogiri'
require 'rack'
require 'rack/server'
require 'thin'

class RandomApp
  METHODS = %w(word sentence paragraph paragraphs)

  def self.create_randomizer(options = {})
    opts = {}

    if options['text']
      opts[:source_material] = File.read("data/#{options['text']}.txt")
    elsif options['paste']
      opts[:source_material] = options['paste']
    elsif options['url']
      html = open(options['url'])
      opts[:source_material] = Nokogiri::HTML(html).text
    end

    LiterateRandomizer.create(opts)
  end

  def self.randomizer(options = {})
    @@randomizer = nil if options['source']
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

    body = data.respond_to?(:each) ? data : [data]
    [200, {'Content-type' => 'application/javascript; charset=utf-8'}, body]
  end
end

Rack::Server.start :app => RandomApp, :Port => 3000

require 'json'
require 'literate_randomizer'
require 'open-uri'
require 'nokogiri'

class MarkovApp
  METHODS = %w(word sentence paragraph paragraphs)

  def create_randomizer(options = {})
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

  def randomizer(options = {})
    @randomizer = nil if options['source']
    @randomizer ||= create_randomizer(options)
  end

  def text(options = {})
    method = METHODS.include?(options['chunk']) ? options['chunk'] : METHODS.first
    randomizer(options).send(method)
  end

  def call(env)
    req = Rack::Request.new(env)
    
    data = text(req.params)

    if req.params['callback'] or req.params['json']
      data = JSON.dump({ :chunk => data })
    end

    if req.params['callback']
      data = "#{req.params['callback']}(#{data})"
    end

    body = data.respond_to?(:each) ? data : [data]
    [200, {'Content-Type' => 'application/javascript; charset=utf-8'}, body]
  end
end

require 'json'
require 'literate_randomizer'
require 'open-uri'
require 'nokogiri'

class MarkovApp
  METHODS = %w(word sentence paragraph paragraphs)

  def call(env)
    req = Rack::Request.new(env)
    
    data = text(req.params)

    data = JSON.dump({ :chunk => data })

    if req.params['callback']
      data = "#{req.params['callback']}(#{data})"
    end

    body = data.respond_to?(:each) ? data : [data]
    [200, {'Content-Type' => 'application/javascript; charset=utf-8'}, body]
  end

  def create_generator(options = {})
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

  def generator(options = {})
    @generator = nil if options['source']
    @generator ||= create_generator(options)
  end

  def text(options = {})
    method = METHODS.include?(options['chunk']) ? options['chunk'] : METHODS.first
    generator(options).send(method)
  end
end

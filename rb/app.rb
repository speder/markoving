require 'json'
require 'literate_randomizer'
require 'open-uri'
require 'nokogiri'

class MarkovApp
  def call(env)
    req = Rack::Request.new(env)

    if req.params['texts']
      data = JSON.dump({ :texts => texts })
    else
      data = JSON.dump({ :chunk => text(req.params) })
    end

    if req.params['callback']
      data = "#{req.params['callback']}(#{data})"
    end

    body = data.respond_to?(:each) ? data : [data]
    [200, {'Content-Type' => 'application/javascript; charset=utf-8'}, body]
  end

  def create_generator(options = {})
    opts = {}

    if options['text']
      if texts.include?(options['text'])
        opts[:source_material] = File.read("data/#{options['text']}.txt")
      end
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

  CHUNKS = %w(word sentence paragraph paragraphs)

  def text(options = {})
    method = CHUNKS.include?(options['chunk']) ? options['chunk'] : CHUNKS.first
    generator(options).send(method)
  end

  def texts
    @texts ||= Dir.new('data').entries.select{ |e| e =~ /.txt$/ }.map{ |e| e.gsub(/.txt/, '') }.sort
  end
end

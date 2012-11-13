require 'json'
require 'literate_randomizer'
require 'open-uri'
require 'nokogiri'

class MarkovApp
  # Rack API
  def call(env)
    req = Rack::Request.new(env)

    if req.params['texts']
      # initialize list of texts
      data = JSON.dump({ :texts => texts })
    else
      # fetch chunk of specified text
      data = JSON.dump({ :chunk => text(req.params) })
    end

    if req.params['callback']
      # jsonp
      data = "#{req.params['callback']}(#{data})"
    end

    body = data.respond_to?(:each) ? data : [data]
    [200, {'Content-Type' => 'application/javascript; charset=utf-8'}, body]
  end

  def create_generator(options = {})
    source = nil

    # initialize random lang generator from:
    if options['paste']
      # pasted text
      source = options['paste']
    elsif options['url']
      # url
      html = open(options['url'])
      source = Nokogiri::HTML(html).text
    elsif options['text']
      # specified text
      if texts.include?(options['text'])
        source = source_file(options['text'])
      end
    end

    # random text file
    source ||= random_source_file

    LiterateRandomizer.create(:source_material => source)
  end

  def generator(options = {})
    @generator = nil if options['source']
    @generator ||= create_generator(options)
  end

  def random_source_file
    name = texts[rand(texts.size - 1)]
    source_file(name)
  end

  def source_file(name)
    File.read("txt/#{name}.txt")
  end

  CHUNKS = %w(word sentence paragraph paragraphs)

  def text(options = {})
    method = CHUNKS.include?(options['chunk']) ? options['chunk'] : CHUNKS.first
    generator(options).send(method)
  end

  def texts
    @texts ||= Dir.new('txt').entries.select{ |e| e =~ /.txt$/ }.map{ |e| e.gsub(/.txt/, '') }.sort
  end
end

# require 'faraday'
require 'faraday_middleware/aws_sigv4'
require 'faraday_middleware'
require 'pp'
require 'json'

require 'dotenv'
Dotenv.load

class SampleES
  attr_reader :host, :index, :conn
  def initialize
    @host = ENV['ES_HOST']
    @index = 'sample_index'
    @conn = Faraday.new(url: host) do |faraday|
      faraday.request :aws_sigv4,
        service: 'es',
        region: 'ap-northeast-1',
        access_key_id: ENV['AWS_ACCESS_KEY_ID'],
        secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
      # see http://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/Sigv4/Signer.html

      faraday.response :json, content_type: /\bjson\b/
      faraday.response :raise_error

      faraday.adapter Faraday.default_adapter
    end
  end

  def count
    conn.get("/#{index}/_count")
  end

  def put_index(index)
    conn.put("/#{index}")
  end

  def put_mapping
    mapping= File.read('./data/mapping.json')

    res = conn.put do |req|
      req.url "/#{index}/_mapping/_doc"
      req.headers['Content-Type'] = 'application/json'
      req.body = mapping
    end
  end

  def bulk_insert
    data = File.read('./data/bulk_insert.json')
    res = conn.post do |req|
      req.url "/_bulk"
      req.headers['Content-Type'] = 'application/x-ndjson'
      req.body = data
    end
  end

  def get_sample_data
    # conn.get
  end
end

es = SampleES.new

res = es.send(ARGV[0])
pp res.body

res = es.count
puts "document count"
pp res.body

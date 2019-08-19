require 'elasticsearch'
require 'faraday_middleware/aws_sigv4'
require 'json'

require 'dotenv'
Dotenv.load

# e.g. https://my-domain.region.es.com
host = ENV['ES_HOST']

region = 'ap-northeast-1'
service = 'es'

client = Elasticsearch::Client.new(url: host) do |f|
  f.request :aws_sigv4,
    service: service,
    region: region,
    access_key_id: ENV['AWS_ACCESS_KEY_ID'],
    secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']#,
  f.adapter Faraday.default_adapter
end

puts client.cat.indices

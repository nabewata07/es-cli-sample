require 'elasticsearch'
require 'faraday_middleware/aws_sigv4'
require 'json'

require 'dotenv'
Dotenv.load

# e.g. https://my-domain.region.es.com
host = ENV['ES_HOST']
index = 'sample_index'
type = '_doc'
id = '1'
document = {
  year: 2007,
  title: '5 Centimeters per Second',
  info: {
    plot: 'Told in three interconnected segments, we follow a young man named Takaki through his life.',
    rating: 7.7
  }
}

region = 'ap-northeast-1'
service = 'es'

client = Elasticsearch::Client.new(url: host) do |f|
  f.request :aws_sigv4,
    service: service,
    region: region,
    access_key_id: ENV['AWS_ACCESS_KEY_ID'],
    secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
    session_token: ENV['AWS_SESSION_TOKEN'] # optional
  f.adapter Faraday.default_adapter
end

puts client.cat.indices

# puts client.index index: index, type: type, id: id, body: document

# lazy_server.rb
require 'sinatra'

get '/' do
  'Hello world from Nancy - a lazy server!'
end

get '/query' do
  serve_request(params)
end

post '/command' do
  serve_request(params)
end

private

def serve_request(p)
  delay = p.has_key?('delay')? p['delay'].to_i : 0
  sleep(delay)
  question = p['question']
  answer = "#{question}"
  response = { status: 'success',
               delay: delay,
               question: question,
               answer: answer
              }
  response.to_json
end

# future.rb

require 'concurrent'
require 'json'
require 'rest-client'
require 'thwait'
require "net/http"
require "uri"
require "typhoeus"



EVENTS = 1000;
DELAY = 1;
URL = 'http://localhost:4567/command'
LEVEL_OF_PARALLELISM = 10

class RestClientWrapper
  def initialize(url, delay)
    @url = url
    @delay = delay
  end

  def ask(q)
    response = RestClient.post @url, :delay => @delay, :question => q, :accept => :json
    obj = JSON.parse(response,:symbolize_names => true)
    obj[:answer]
  end

  def ask_all(qs)
    answers = []
    qs.each_entry { |q|
      answer = ask(q)
      answers.push(answer)
    }
    answers
  end
end

class NetHttpClient
  def initialize(url, delay)
    @url = url
    @delay = delay
  end

  def ask(q)
    uri = URI.parse(@url)
    response = Net::HTTP.post_form(uri, {:delay => @delay, :question => q, :accept => :json})
    obj = JSON.parse(response,:symbolize_names => true)
    obj[:answer]
  end

  def ask_all(qs)
    answers = []
    qs.each_entry { |q|
      answer = ask(q)
      answers.push(answer)
    }
    answers
  end
end

class TyphoeusClient
  def initialize(url, delay)
    @url = url
    @delay = delay
  end

  def ask(q)
    response = Typhoeus.post(@url, body: { :delay => @delay, :question => q, :accept => :json })
    obj = JSON.parse(response.options[:response_body], :symbolize_names => true)
    obj[:answer]
  end

  def ask_all(qs)
    answers = []
    qs.each_entry { |q|
      answer = ask(q)
      answers.push(answer)
    }
    answers
  end
end

Setting = Struct.new(:events, :level_of_parallelism)

class SequentialProcessing
  def initialize(events, source)
    @events = events
    @source = source
  end

  def run
    questions = (1..@events).to_a
    @source.ask_all(questions)
  end
end

class FutureProcessing
  def initialize(setting, source)
    @setting = setting
    @source = source
  end

  def run
    pool = Concurrent::FixedThreadPool.new(@setting.level_of_parallelism)
    latch = Concurrent::CountDownLatch.new(@setting.level_of_parallelism)
    futures = (1..EVENTS).group_by{|i| i%LEVEL_OF_PARALLELISM}
                         .collect{|i| i[1]}
                         .collect {|i|
                             Concurrent::Future.execute(executor: pool){
                               answers = @source.ask_all(i)
                               latch.count_down
                               answers
                             }
                          }
    latch.wait()
    futures.map{|f| f.value}
  end
end


#client = RestClientWrapper.new(URL, DELAY)
client = TyphoeusClient.new(URL, DELAY)
setting = Setting.new(EVENTS, LEVEL_OF_PARALLELISM)

# Mono (synchronous + Single-threaded) client
# start = Time.now
# sequential_processing = SequentialProcessing.new(EVENTS, client)
# answer = sequential_processing.run
# puts "\n\n\nSingle-threaded synchronous: #{Time.now - start} seconds"
# p answer


# Future client
start = Time.now
future_processing = FutureProcessing.new(setting, client)
answer = future_processing.run
puts "\n\n\nConcurrent Future: #{Time.now - start} seconds"
p answer

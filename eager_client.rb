require 'concurrent'
require 'json'
require 'rest-client'
require 'thwait'

# for i in 0..5
#   puts Time.now
#   response = RestClient.post 'http://localhost:4567/command', :delay => i, :question => "question #{i}", :accept => :json
#   puts JSON.parse(response,:symbolize_names => true)
# end


# ---------------------------
# Through-put testing
# 1000 events to process, x seconds web call for each events
# Time taken to process all of them
# And come back with correct result
# ---------------------------

EVENTS = 30;
DELAY = 1;
URL = 'http://localhost:4567/command'
LEVEL_OF_PARALLELISM = 4

def ask_question(delay, iteration)
  response = RestClient.post URL, :delay => delay, :question => "question :#{iteration}", :accept => :json
  obj = JSON.parse(response,:symbolize_names => true)
  obj[:answer]
end

def ask_questions(delay, items)
  answers = []
  items.each_entry { |i|
    answer = ask_question(delay, i)
    answers.push(answer)
  }
  answers
end

#Single-threaded, synchronous solution
# start = Time.now
# answers = ask_questions(DELAY, (1..EVENTS))
# finish = Time.now
# puts "\n\n\nSingle-threaded synchronous: #{finish - start} seconds"
# p answers

# Multi-threaded, synchronous solution
# Create a bunch of threads, divide and conquer
start = Time.now
answers = Concurrent::Array.new
threads = (1..EVENTS).group_by{|i| i%LEVEL_OF_PARALLELISM}
                     .collect{|i| i[1]}
                     .collect {|i|
                         thread = Thread.new do
                           thread_answers = ask_questions(DELAY, i)
                           answers.push(thread_answers)
                         end
                      }
ThreadsWait.all_waits(*threads)

finish = Time.now
puts "\n\n\nMulti-threaded synchronous: #{finish - start} seconds"
p answers

# Async solution: Using Promise



# Callback solution

require 'concurrent'

pool = Concurrent::FixedThreadPool.new(20)

futures = (1..100).collect do |i|
  Concurrent::Future.execute(executor: pool) {
    sleep (1)
    "input: #{i}"
  }
end

values = futures.collect{ |f| f.value }

puts values

# TOTAL = 10
# LEVEL = 3
# DELAY = 5
#
# puts 'Expecting Future:'
# latch = Concurrent::CountDownLatch.new(LEVEL)
# futures = []
# messages = []
# for i in 1..LEVEL
#   items = (1..TOTAL).find_all {|j| j % LEVEL == (i-1)}.to_a
#   messages.push(items)
#   puts "For loop: #{messages[i-1]}"
#
#   futures.push(Concurrent::Future.new {
#     local_val = Array.new(items)
#     puts "Future creation: #{local_val}"
#     sleep(DELAY)
#     latch.count_down
#   })
#   #futures.push(future)
#
# end
#
# puts "\n\nFutures created. Going to execute now.\n\n"
#
# futures.each_entry { |f|
#   f.execute
# }
#
# latch.wait()
#
# puts "Done"





# ========================
# The peril of concurrency
# ========================
# Local variable's value has been updated by the time
#   the future is evaluated

# latch = Concurrent::CountDownLatch.new(LEVEL)
# futures = []
# for i in 1..LEVEL
#   items = (1..TOTAL).find_all {|j| j % LEVEL == (i-1)}.to_a
#   puts "For loop: #{items}"
#   future = Concurrent::Future.new {
#     puts "Future creation: #{items}"
#     #sleep(DELAY)
#     latch.count_down
#   }
#   futures.push(future)
#   future.execute
# end
# latch.wait()
#
# puts "Done"

# await.rb

require 'concurrent'

latch = Concurrent::CountDownLatch.new(3)

waiter = Thread.new do
  latch.wait()
  puts ("Waiter released")
end

decrementer = Thread.new do
  sleep(1)
  latch.count_down
  puts latch.count

  sleep(1)
  latch.count_down
  puts latch.count

  sleep(1)
  latch.count_down
  puts latch.count
end

[waiter, decrementer].each(&:join)

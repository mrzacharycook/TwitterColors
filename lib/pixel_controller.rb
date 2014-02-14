require_relative 'color_getter'
require_relative 'pixel_setter'
require 'redis'
require 'color'
require 'optparse'

#Maximum time redis blocking pop should wait in seconds
MAX_WAIT_TIME = 60

class PixelController
  #Initialize the PixelController with device parameters ["serial port", baud, pixels],
  def initialize(port,baud,pixels)
      #then create a new PixelSetter with the parameters
      puts 'starting alamode'
      @alamode = PixelSetter.new(port,baud,pixels)
      #and create a new Redis connection.
      puts 'starting redis'
      @redis = Redis.new
      #Clean out redis if there were leftovers from last time (DELETES ALL REDIS DATA ON LOCAL HOST!!!!)
      puts 'cleaning redis'
      @redis.flushall
  end

  #Call run with a number of tweets to process and a brightness adjustment percentage
  def run
    #and initialize a new ColorGetter using the parameters passed in.
    puts 'creating color getter'
    color_getter = ColorGetter.new
    #Create a new thread to run the color getter, allowing for tweets to be gathered
    # while being presented at the same time later in our process.
    color_getter_thread = Thread.new {
    color_getter.get_tweet_colors
    }

    #Pop out one of the items and check to see if it's our done state.
    while queue_object = @redis.brpop('tweet_queue', ::MAX_WAIT_TIME)
      #If we have something to do, send the queue object's value (array[1]) to the PixelSetter
      if queue_object.nil?
      else
        @alamode.increment_pixel(queue_object[1])
      end
    end

    #If the color_getter thread is still running (it shouldn't be), it should be killed at this point.
    if color_getter_thread.alive?
      color_getter_thread.kill
    end
  end
end

#Parameters for PixelController initialization are port, baud, and pixel count. e.g.("/dev/ttyS0",9600,8)
controller = PixelController.new("/dev/ttyS0",9600, 8)

#Parameters for PixelController's run method are number of tweets to process, and the percent change in brightness of leds. e.g.(1000,"-90")
controller.run
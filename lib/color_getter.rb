require 'twitter'
require 'json'
require 'color'
require 'redis'

class ColorGetter
  #Initialize the ColorGetter with an amount of tweets to process and the brightness adjustment value
  def initialize
    #Read the config file
    json_config = JSON.parse(File.read('twitter_config.json'))
    #and create a new connection to redis
    @redis = Redis.new
    #then create a new streaming Twitter object.
    @client = Twitter::Streaming::Client.new do |config|
      config.consumer_key = json_config['consumer_key']
      config.consumer_secret = json_config['consumer_secret']
      config.access_token = json_config['access_token']
      config.access_token_secret = json_config['access_token_secret']
    end
  end

  #Call get_tweet_colors
  def get_tweet_colors
    #Start sampling data from the Twitter object.
    puts 'starting sample'
    @client.sample do |object|
      #If the object is a Tweet (there are multiple objects that can come through the sample),
      if object.is_a?(Twitter::Tweet)
        #extract every color (by name) from the tweet text into an array.
        colors = Color::RGB.extract_colors(object.text, mode = :name)
        #For each item in the colors array,
        colors.compact.each do |color|
          #check for a nil return.
          if color.nil?
          #If it's not nil,
          else
            #adjust the brightness so we aren't blinding ourselves with these bright LEDs
            dimmed_color = color.adjust_brightness(0)
            #and push this color's RGB values into redis
            @redis.lpush('tweet_queue',"#{dimmed_color.red},#{dimmed_color.green},#{dimmed_color.blue}")
          end
        end
      end
    end
  end
end
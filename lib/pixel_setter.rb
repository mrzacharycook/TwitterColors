require 'serialport'

class PixelSetter

  #Initialize the PixelSetter class
  def initialize(port, baud, pixels)
    #by creating the serial connection on a specified port with a baud speed
    puts "starting serial"
    @serial_device = SerialPort.new "#{port}", baud
    #and creating a variable to track the number of times this instance has changed a pixel
    @count_of_color_changes = 0
    #and setting the number of pixels we have to address for this specific PixelSetter,
    # subtracting 1 since we start addressing pixels at 0
    @pixel_count = pixels - 1
  end

  #Call increment_pixel, passing in the parameter for the rgb_color we want to initialize
  def increment_pixel(rgb_color)
    #and get the value of the last pixel.
    aggregate_pixel = @pixel_count
    #Set the rgb color of a pixel and send it to the writer
    self.write_pixel(rand(@pixel_count),rgb_color)
    #and increment the count tracking the number of pixels we've updated
    @count_of_color_changes += 1
    #Take the number of color changes we've processed, and see if it's a multiple of 33
    if (@count_of_color_changes % 33) == 0
      #if it is, set the white value to be the result of the division
      white_value = @count_of_color_changes / 33
      #create a string formatted to the rgb color string
      white_rgb_color = Array.new(3,white_value).join ','
      #and set the aggregation pixel (our last pixel) to the new white level
      self.write_pixel(aggregate_pixel,white_rgb_color)
    end
  end

  ## write_pixel will update the specified pixel with the rgb value given
  #   this will write out to the serial device a string in format Cp,r,g,b
  #   C = beginning of string to parse
  #   p = pixel number
  #   red,green,blue = int value of brightness for red, green, and blue values.
  def write_pixel(pixel,rgb_color)
    rgb_vals = rgb_color.split(',')
    #Maximum value for these fields is 255, set it to 255 if a greater values is passed
    rgb_vals.map! {|value| [value.to_f, 255].min}
    #Set the standard update string Cp,r,g,b
    update_string = "C#{pixel},#{rgb_vals.join ','}"
    #Update the alamode pixels using the standard update string filled in with the pixel and rgb values.
    @serial_device.write update_string
  end

  #Call reset_pixels,
  def reset_pixels
    #which creates a color equal to turning off the pixels
    turn_off_color = '0,0,0'
    #enumerates each pixel into an array
    pixels = *(0..@pixel_count)
    #and sets each one to off.
    pixels.each do |pixel|
      self.write_pixel(pixel,turn_off_color)
    end
  end
end
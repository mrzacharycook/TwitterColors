require 'serialport'

class PixelSetter
  @count_of_color_changes = 0

  #Create a new serial instance to talk to the Alamode
  def create_alamode_connection
    SerialPort.new '/dev/ttyS0', 9600
  end

  def increment_pixel(pixels,red,green,blue,increment_count,serial_device)
    aggregate_pixel = pixels

    self.write_pixel(rand(pixels),red,green,blue,serial_device)

    if (increment_count % 3) == 0
      white_value = increment_count / 33
      self.write_pixel(aggregate_pixel,white_value,white_value,white_value,serial_device)
    end
  end

  ## write_pixel will update the specified pixel with the rgb value given
  #   this will write out to the serial device a string in format Cp,r,g,b
  #   C = beginning of string to parse
  #   p = pixel number
  #   red,green,blue = int value of brightness for red, green, and blue values.
  def write_pixel(pixel,red,green,blue,serial_device)
    #Maximum value for these fields is 255, set it to 255 if a greater values is passed
    [red, green, blue].map! {|value| value = 255 if value > 255}

    #Set the standard update string Cp,r,g,b
    update_string = "C#{pixel},#{red},#{green},#{blue}"

    #Update the alamode pixels using the standard update string filled in with the pixel and rgb values.
    serial_device.write update_string
  end

  #Enumerate the pixels, then iterate through each pixel and turn it off.
  def reset_pixels(pixel_count,serial_device)
    pixels = *(0..pixel_count)
    pixels.each do |pixel|
      self.write_pixel(pixel,0,0,0,serial_device)
    end
  end
end
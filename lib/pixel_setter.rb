require 'rubygems'
require 'serialport'

#Create an array with values numbering the LEDs in your strip
PIXELS=*(0..7)

#Values of brightness for LEDs to sort, shuffled for random sorting
@my_list = [220,40,150,60,120,90,180,20].shuffle

#Create a new serial instance to talk to the Alamode
@alamode = SerialPort.new "/dev/ttyS0", 9600

## write_pixels will update each pixel with the brightness value in the list by index, where index is the number of the pixel.  Accepts an array as a parameter.
#   this will write out to the serial device a string in format Cp,r,g,b
#   C = beginning of string to parse
#   p = pixel number
#   r,g,b = int value of brightness for red, green, and blue values.
def write_pixels(list)
  PIXELS.each do |pixel|
    #Initialize the value of each color brightness to be 0 for proper logging.  We have only 1 rgbval in this case because we want white LEDs.
    rgbval = 0

    #If the array index we're attempting to grab has a nil value, do nothing.  Otherwise set the rgbval to the brightness value contained within @my_list for index[pixel].
    if list[pixel].nil?
    else
      rgbval = list[pixel]
    end

    #Set the standard update string Cp,r,g,b
    updatestring = "C#{pixel},#{rgbval},#{rgbval},#{rgbval}"

    #Update the alamode pixels using the standard update string filled in with the pixel and rgbval value.
    @alamode.write updatestring

    #Log the update string to console and sleep for a short period of time to allow easier visibility on the LED panel.
    puts updatestring
    sleep(0.15)
  end
end

def merge_sort(list)
  #Base Case:  If the size of our list is 1 or less, stop splitting.
  if list.size <= 1
    return list
  end

  #Deliver the list to the halves method, and get 2 arrays (left and right).
  left,right = halves(list)

  #Recursively split the halves, then merge and sort.
  return iterativemerge(merge_sort(left),
                        merge_sort(right))
end

def halves(list)
  #Split list into 2 sections, and use the ceiling function to maintain the full split in case of an odd number.
  # Returns 2 arrays
  list.each_slice((list.size / 2).ceil).to_a
end

def iterativemerge(left,right)
  #Create result array to append sorted values to.
  result = []

  #While left and right aren't empty, compare the first elements of each, remove the lower number from the array and insert into result.
  while (not left.empty? and not right.empty?) do
    if left.first <= right.first
      result << left.shift
    else
      result << right.shift
    end
  end

  #Left or right should be empty by the time it reaches here, but an element will still exist in left or right.
  # Append both to the result, then update the pixel strip with the final result.
  result = result + left + right
  write_pixels(result)
  return result
end

#Set up the pixels to display the unordered list and pause for effect.
write_pixels(@my_list)
sleep(2)

#Start the mergesort show.
merge_sort(@my_list)
sleep(2)

#Turn off all the pixels.
write_pixels(Array.new(8, 0))
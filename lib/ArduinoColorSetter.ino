// include the neo pixel library
#include <Adafruit_NeoPixel.h>

// The number of LEDs being driven.
static const int NUM_LEDS = 8;

// Parameter 1 = number of pixels in strip
// Parameter 2 = pin number (most are valid)
// Parameter 3 = pixel type flags, add together as needed:
//   NEO_RGB     Pixels are wired for RGB bitstream
//   NEO_GRB     Pixels are wired for GRB bitstream
//   NEO_KHZ400  400 KHz bitstream (e.g. FLORA pixels)
//   NEO_KHZ800  800 KHz bitstream (e.g. High Density LED strip)

Adafruit_NeoPixel strip = Adafruit_NeoPixel(
  NUM_LEDS,             // Number of pixels in strip
  7,                   // Pin number (most are valid)
  NEO_GRB + NEO_KHZ800  //  pixel type flags, add together as needed:
                          //   NEO_RGB     Pixels are wired for RGB bitstream
                          //   NEO_GRB     Pixels are wired for GRB bitstream
                          //   NEO_KHZ400  400 KHz bitstream (e.g. Old FLORA pixels)
                          //   NEO_KHZ800  800 KHz bitstream (e.g. New FLORA pixels and most WS2811 strips)
);

//Initialize integers that we'll parse from the Serial feed later.
int pixel = 0;
int red = 0;
int green = 0;
int blue = 0;

void setup() {
  // Init the NeoPixel library and turn off all the LEDs
  strip.begin();
  strip.show();

  // Initialize serial and wait for port to open:
  Serial.begin(9600);
  while (!Serial) {
    ; // wait for port to be ready
  }

  // Tell the computer that we're ready for data
  Serial.println("READY");
}


void loop() {
  // listen for serial:
  if (Serial.available() > 0) {
    // If we see a feed from the Serial starting with C, begin parsing out integers for the values below
    if (Serial.read() == 'C') {    // string should start with C
      pixel = Serial.parseInt();   // then an ASCII number for pixel number
      red = Serial.parseInt();     // then an ASCII number for red
      green = Serial.parseInt();   // then an ASCII number for green
      blue = Serial.parseInt();    // then an ASCII number for blue
    }
  }

    // For the given pixel, set the color
    strip.setPixelColor(pixel, red, green, blue);

    // Send the values to the strip and update
    strip.show();
}
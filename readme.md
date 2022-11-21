# kestrel

kestrel is a bare-metal forth system, built on top of the excellent pijFORTHos, which is in turn built on Jonesforth. pijFORTHos is very bare bones. it has a forth repl and some standard words, but no peripheral interfacing or advanced functionality. kestrel aims to provide peripheral interfacing and eventually a more full-fat system. it's unlikely that kestrel will ever run sysV binaries, but hopefully some day it will be self hosting.

## building and running

kestrel is pretty much hardwired for raspberry pi 1b. the b+ might work but i'm unable to test it, as i don't own one. 2 and upwards definitely won't, because the memory-mapped IO is in a different place.

pijFORTHos has its own instructions for building and running. i've left those pretty much untouched. the one thing i would add is that it's possible to use an arduino as a serial adaptor. connect RX on the pi to RX on the arduino, TX on the pi to TX on the arduino, connect the grounds together, connect the arduino's RST to ground, and connect the arduino's 5v to the pi's 5v. if you're worried about the arduino's 5v uart causing problems with the pi's 3v3 uart, don't worry i do it like this and my pi hasn't exploded yet.

to send code to the pi, make sure to turn screen slowpaste or an equivalent on. pasting instantly overruns a buffer somewhere and causes characters to get dropped.

[slurp.sh](slurp.sh) is a shell script that grabs jonesforth.f, kestrel.f and gpio.f and feeds them into a screen session named "forth". the utility of this is obvious.

## kestrel functionality

as it stands, kestrel only has basic gpio and timer interfacing. everything else is a work in progress.

the only modification made to the assembly source is the addition of some long arithmetic operations that operate on double width numbers.

### gpio

[gpio.f](kestrel/gpio.f) contains functions for talking to the gpio pins. bear in mind it uses BCM pin numbers, not wiringpi or anything else like that. also bear in mind that if you change the functions of pins 15 or 14 the uart stops working.

GPIO_INPUT et al are constants for the 3-bit function ids. GPIO_FNMASK is a bitmask, and GPIOBASE etc are addresses. you shouldn't need to use those unless you're implementing more functionality.

GPIOSETFN takes a pin and a function id and sets the function for that pin. it will do undefined behaviour if you use a pin number bigger than 54. so don't. SETGPIO{IN, OUT} are shortcuts for input and output.

SETGPIO and CLRGPIO set and clear the pins, respectively. UB will occur on pin numbers greater than 54, and if the pin isn't set to output. WRITEGPIO writes a value based on a boolean from the stack.

READGPIO returns 0 if a pin is low, and any nonzero number if it's high. again, UB on pins > 54 and pins not set to input.

to check pin functions, you can use GETGPIOFN and CKGPIO{IN, OUT}.

### timer

[timer.f](kestrel/timer.f) contains functions for talking to the system timer.

the BCM2835 has 2 timers: the ARM timer and the system timer. the pijFORTHos morse code demo uses the ARM timer. however, that timer overflows every 71 minutes. the system timer is 64 bit, and it overflows after around 60 thousand years.

the time words here all use 32 bit values, because time is meaningless as a standalone value. you almost always want "time since" or "time until" or "is it later than this time"; you never do arithmetic on the time itself. it is for this reason that Rust (for example) models Instant as opaque. however, i have exposed the full 64 bits just in case you have a system that needs to wait more than 71 minutes.

use TIME@ to get the full time, use TIMEL@ to get the lower 32 bits. use WAITUNTIL to wait until a specified instant, use WAITFOR to wait for a specified amount of microseconds. i recommend WAITFOR for the reasons given above. use SINCE to get the duration since a given instant.

(
    hello world for kestrel
    depends on gpio.f, which in turn depends on kestrel.f and jonesforth.f

    this file literally just turns on the ACT led on the pi. the led is wired to pin 16, active low.
)

16 SETGPIOOUT \ set pin 16 as an output

16 CLRGPIO \ turn led on

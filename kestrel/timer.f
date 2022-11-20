(
    timer access for pijFORTHos

    the BCM2835 has 2 timers: the ARM timer and the system timer. the pijFORTHos morse code demo uses the ARM timer. however, that timer overflows every 71 minutes.
    the system timer is 64 bit, and it overflows after around 60 thousand years.
)

BASESAVE HEX

MMIOBASE 3000 + CONSTANT TIMERBASE
TIMERBASE 4 + CONSTANT FREECTRLOW
TIMERBASE 8 + CONSTANT FREECTRHI

DECIMAL

(
    here we define a long multiplication word. this takes a double length number and multiplies it by a single length number
)

: L* ( ah al b -- abh abl )
    (
        we need
        - al b O*
        - ah b *
    )
    TUCK O* ( ah b albh albl )
    2SWAP * ( albh albl ahb )
    ROT + SWAP
;

: TIME@ FREECTRHI @ FREECTRLOW @ ; ( -- timeh timel )
: MSECS> 1000 L* ;
: SECS> 10000000 L* ;

BASERESTORE

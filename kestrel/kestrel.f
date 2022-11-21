(
    for pijFORTHos
)

: BASESAVE
    BASE @
;
: BASERESTORE 
    BASE !
;

: STRCONST
    WORD CREATE \ get the next word and create a new dictonary entry
    
;

: ESC 16# 1B ;
: CLEAR #
    ESC EMIT ." [H"
    ESC EMIT ." [2J"
    ESC EMIT ." [3J"
;

(
    here we define some long maths. this is mainly used for timer stuff (see timer.f)

    O*, L+ and L- are written in assembly
)

BASESAVE HEX

20000000 CONSTANT MMIOBASE \ mmio base address

BASERESTORE

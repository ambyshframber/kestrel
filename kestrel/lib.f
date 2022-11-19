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

BASESAVE HEX

20000000 CONSTANT MMIOBASE \ mmio base address

BASERESTORE

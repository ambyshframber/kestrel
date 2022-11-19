(
    gpio access words
)

BASESAVE BINARY

000 CONSTANT GPIO_INPUT
001 CONSTANT GPIO_OUTPUT
100 CONSTANT GPIO_ALTFN0
101 CONSTANT GPIO_ALTFN1
110 CONSTANT GPIO_ALTFN2
111 CONSTANT GPIO_ALTFN3
011 CONSTANT GPIO_ALTFN4
010 CONSTANT GPIO_ALTFN5

111 CONSTANT GPIO_FNMASK

HEX

MMIOBASE 200000 + CONSTANT GPIOBASE

GPIOBASE 1C + CONSTANT GPIOSETBASE
GPIOBASE 28 + CONSTANT GPIOCLRBASE
GPIOBASE 34 + CONSTANT GPIOLEVBASE

DECIMAL

: SETGPIOFN ( pin fn -- )
    SWAP ( fn pin )
    \ 10 pins per fn select reg, 3 bits per pin, 4 bytes per reg
    10 /MOD ( fn ofs/3 reg )
    4 * GPIOBASE + SWAP 3 * ( fn reg_address ofs )
    GPIO_FNMASK OVER LSHIFT INVERT ( fn reg_address ofs ~mask )
    ROT TUCK ( fn ofs reg_address ~mask reg_address )
    @ AND ( fn ofs reg_address masked_val )
    2SWAP ( ra mv fn ofs )
    LSHIFT OR ( reg_addr value )
    SWAP !
;
: GETGPIOFN ( pin -- fn )
    10 /MOD ( ofs/3 reg )
    4 * GPIOBASE + @ SWAP 3 * ( regv ofs )
    GPIO_FNMASK OVER LSHIFT ( regv ofs mask )
    ROT AND ( ofs fnshfted )
    SWAP RSHIFT
;
: SETGPIOIN ( pin -- ) GPIO_INPUT SETGPIOFN ;
: SETGPIOOUT ( pin -- ) GPIO_OUTPUT SETGPIOFN ;

: CKGPIOIN ( pin -- is_input ) GETGPIOFN GPIO_INPUT = ;
: CKGPIOOUT ( pin -- is_output ) GETGPIOFN GPIO_OUTPUT = ; 

: SETGPIO ( pin -- )
    \ 32 pins per register, 1 bit per pin, 4 bytes per reg
    32 /MOD ( ofs reg )
    4 * GPIOSETBASE + 1 ROT LSHIFT ( r_addr bit )
    SWAP !
;
: CLRGPIO ( pin -- )
    \ 32 pins per register, 1 bit per pin, 4 bytes per reg
    32 /MOD ( ofs reg )
    4 * GPIOCLRBASE + 1 ROT LSHIFT ( r_addr bit )
    SWAP !
;
: WRITEGPIO ( pin val -- )
    IF SETGPIO ELSE CLRGPIO THEN
;

: READGPIO ( pin -- state )
    \ state is 0 for low, non-zero for high
    32 /MOD ( ofs reg )
    4 * GPIOLEVBASE + @ 1 ROT LSHIFT AND
;

BASERESTORE

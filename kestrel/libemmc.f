(
    rpi 1 emmc access in forth
)

300000 MMIOBASE + CONSTANT EMMCBASE

: EMMCCONST \ define an offset from the emmc base ( ofs -- )
    EMMCBASE + CONSTANT
;




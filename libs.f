\ Annotation has been removed from this file to expedite processing.
\ See the files in the /annexia/ for a full Literate Code tutorial, it's great!

: '\n' 10 ;
: BL 32 ;
: ':' [ CHAR : ] LITERAL ;
: ';' [ CHAR ; ] LITERAL ;
: '(' [ CHAR ( ] LITERAL ;
: ')' [ CHAR ) ] LITERAL ;
: '"' [ CHAR " ] LITERAL ;
: 'A' [ CHAR A ] LITERAL ;
: '0' [ CHAR 0 ] LITERAL ;
: '-' [ CHAR - ] LITERAL ;
: '.' [ CHAR . ] LITERAL ;
: ( IMMEDIATE 1 BEGIN KEY DUP '(' = IF DROP 1+ ELSE ')' = IF 1- THEN THEN DUP 0= UNTIL DROP ;
: SPACES ( n -- ) BEGIN DUP 0> WHILE SPACE 1- REPEAT DROP ;
: WITHIN -ROT OVER <= IF > IF TRUE ELSE FALSE THEN ELSE 2DROP FALSE THEN ;
: ALIGNED ( c-addr -- a-addr ) 3 + 3 INVERT AND ;
: ALIGN HERE @ ALIGNED HERE ! ;
: C, HERE @ C! 1 HERE +! ;
: S" IMMEDIATE ( -- addr len )
	STATE @ IF
		' LITS , HERE @ 0 ,
		BEGIN KEY DUP '"'
                <> WHILE C, REPEAT
		DROP DUP HERE @ SWAP - 4- SWAP ! ALIGN
	ELSE
		HERE @
		BEGIN KEY DUP '"'
                <> WHILE OVER C! 1+ REPEAT
		DROP HERE @ - HERE @ SWAP
	THEN
;
: ." IMMEDIATE ( -- )
	STATE @ IF
		[COMPILE] S" ' TELL ,
	ELSE
		BEGIN KEY DUP '"' = IF DROP EXIT THEN EMIT AGAIN
	THEN
;
: DICT WORD FIND ;
: VALUE ( n -- ) WORD CREATE DOCOL , ' LIT , , ' EXIT , ;
: TO IMMEDIATE ( n -- )
        DICT >DFA 4+
	STATE @ IF ' LIT , , ' ! , ELSE ! THEN
;
: +TO IMMEDIATE
        DICT >DFA 4+
	STATE @ IF ' LIT , , ' +! , ELSE +! THEN
;
: ID. 4+ COUNT F_LENMASK AND BEGIN DUP 0> WHILE SWAP COUNT EMIT SWAP 1- REPEAT 2DROP ;
: ?HIDDEN 4+ C@ F_HIDDEN AND ;
: ?IMMEDIATE 4+ C@ F_IMMED AND ;
: WORDS LATEST @ BEGIN ?DUP WHILE DUP ?HIDDEN NOT IF DUP ID. SPACE THEN @ REPEAT CR ;
: FORGET DICT DUP @ LATEST ! HERE ! ;
: CFA> LATEST @ BEGIN ?DUP WHILE 2DUP SWAP < IF NIP EXIT THEN @ REPEAT DROP 0 ;
: SEE
	DICT HERE @ LATEST @
	BEGIN 2 PICK OVER <> WHILE NIP DUP @ REPEAT
	DROP SWAP ':' EMIT SPACE DUP ID. SPACE
	DUP ?IMMEDIATE IF ." IMMEDIATE " THEN
	>DFA BEGIN 2DUP
        > WHILE DUP @ CASE
		' LIT OF 4 + DUP @ . ENDOF
		' LITS OF [ CHAR S ] LITERAL EMIT '"' EMIT SPACE
			4 + DUP @ SWAP 4 + SWAP 2DUP TELL '"' EMIT SPACE + ALIGNED 4 -
		ENDOF
		' 0BRANCH OF ." 0BRANCH ( " 4 + DUP @ . ." ) " ENDOF
		' BRANCH OF ." BRANCH ( " 4 + DUP @ . ." ) " ENDOF
		' ' OF [ CHAR ' ] LITERAL EMIT SPACE 4 + DUP @ CFA> ID. SPACE ENDOF
		' EXIT OF 2DUP 4 + <> IF ." EXIT " THEN ENDOF
		DUP CFA> ID. SPACE
	ENDCASE 4 + REPEAT
	';' EMIT CR 2DROP
;
: :NONAME 0 0 CREATE HERE @ DOCOL , ] ;
: ['] IMMEDIATE ' LIT , ;
: EXCEPTION-MARKER RDROP 0 ;
: CATCH ( xt -- exn? ) DSP@ 4+ >R ' EXCEPTION-MARKER 4+ >R EXECUTE ;
: THROW ( n -- ) ?DUP IF
	RSP@ BEGIN DUP R0 4-
        < WHILE DUP @ ' EXCEPTION-MARKER 4+
		= IF 4+ RSP! DUP DUP DUP R> 4- SWAP OVER ! DSP! EXIT THEN
	4+ REPEAT DROP
	CASE
		0 1- OF ." ABORTED" CR ENDOF
		." UNCAUGHT THROW " DUP . CR
	ENDCASE QUIT THEN
;
: ABORT ( -- ) 0 1- THROW ;
: PRINT-STACK-TRACE
	RSP@ BEGIN DUP R0 4-
        < WHILE DUP @ CASE
		' EXCEPTION-MARKER 4+ OF ." CATCH ( DSP=" 4+ DUP @ U. ." ) " ENDOF
		DUP CFA> ?DUP IF 2DUP ID. [ CHAR + ] LITERAL EMIT SWAP >DFA 4+ - . THEN
	ENDCASE 4+ REPEAT DROP CR
;
: BINARY ( -- ) 2 BASE ! ;
: OCTAL ( -- ) 8 BASE ! ;
: 2# BASE @ 2 BASE ! WORD NUMBER DROP SWAP BASE ! ;
: 8# BASE @ 8 BASE ! WORD NUMBER DROP SWAP BASE ! ;
: # ( b -- n ) BASE @ SWAP BASE ! WORD NUMBER DROP SWAP BASE ! ;
: UNUSED ( -- n ) PAD HERE @ - 4/ ;
: WELCOME
	S" TEST-MODE" FIND NOT IF
		." JONESFORTH VERSION " VERSION . CR
		UNUSED . ." CELLS REMAINING" CR
		." OK "
	THEN
;
WELCOME
HIDE WELCOME
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

BASESAVE HEX

20000000 CONSTANT MMIOBASE \ mmio base address

BASERESTORE
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
: SETGPIOIN ( pin -- ) GPIO_INPUT SETGPIOFN ;
: SETGPIOOUT ( pin -- ) GPIO_OUTPUT SETGPIOFN ;

: GETGPIOFN ( pin -- fn )
    10 /MOD ( ofs/3 reg )
    4 * GPIOBASE + @ SWAP 3 * ( regv ofs )
    GPIO_FNMASK OVER LSHIFT ( regv ofs mask )
    ROT AND ( ofs fnshfted )
    SWAP RSHIFT
;
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
: WRITEGPIO ( val pin -- )
    SWAP IF SETGPIO ELSE CLRGPIO THEN
;

: READGPIO ( pin -- state )
    \ state is 0 for low, non-zero for high
    32 /MOD ( ofs reg )
    4 * GPIOLEVBASE + @ 1 ROT LSHIFT AND
;

BASERESTORE

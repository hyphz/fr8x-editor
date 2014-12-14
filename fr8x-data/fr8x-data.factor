! Copyright (C) 2014 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel locals accessors math sequences math.bitwise bitstreams io.files io xml io.encodings.binary xml.traversal strings
  assocs math.parser combinators fry arrays io.encodings.ascii io.encodings.string ;
FROM: io => read ;
RENAME: read bitstreams => bsread 

IN: fr8x-data 

TUPLE: chunkinfo
{ name string }
{ size integer } 
{ count integer } 
{ offset integer } ;

ERROR: setfileerror desc ;

: throw-set-loading-error ( desc -- ) setfileerror boa throw ;

: get-header ( -- bin ) 
    "\x8d" read-until 
    [ "Missing end of preamble marker" throw-set-loading-error ] unless ;

: chop-junk ( bin -- slice ) 
   [ 60 swap index 
     [ "Missing XML document in preamble" throw-set-loading-error 0 ] unless* 
   ] keep swap tail-slice ; 

: get-chunk-tags ( head -- vector ) children>> 1 swap nth children-tags ;

: get-int-attr ( attrs name -- int ) 
    swap at* 
    [ "Missing expected attribute in XML preamble" throw-set-loading-error ] unless
    string>number ;
 
: parse-chunk-tag ( tag -- chunkspec ) 
    [ name>> main>> ] keep 
    attrs>>
    "size" "number" "offset" [ get-int-attr ] tri-curry@ tri 
    chunkinfo boa ;

: parse-chunk-tags ( vector -- chunks ) [ parse-chunk-tag ] map ;

: parse-header ( -- chunks ) get-header chop-junk bytes>xml get-chunk-tags parse-chunk-tags ;

: load-chunk ( chunkinfo offset -- chunkdata ) 
    swap
    [ offset>> + seek-absolute seek-input ] keep 
    [ name>> ] [ count>> ] [ size>> ] tri '[ _ read ] replicate 
    2array ;

: load-chunks ( chunkinfos -- chunkdatas ) tell-input 1 - [ load-chunk ] curry map ;

: parse-set-file ( -- head ) parse-header load-chunks ;

: load-set-file ( fn --  head ) binary [ parse-set-file ] with-file-reader ;

: test ( -- head ) "FR-8X_SET_001.ST8" load-set-file ;

: get-chunk ( alist id -- chunk ) 
    swap at* 
    [ "Missing chunk type" throw-set-loading-error ] unless
    [ <msb0-bit-reader> ] map ;

:: bsread-string ( bitreader count width -- string ) 
    count [ width bitreader bsread ] replicate ascii decode ;
    

TUPLE: scData creator type ver num name reverb-character reverb-prelpf reverb-time reverb-delay reverb-predelay reverb-level 
   reverb-selected chorus-prelpf chorus-feedback chorus-delay chorus-rate chorus-depth chorus-sendrev chorus-senddelay 
   chorus-level chorus-selected delay-prelpf delay-timecenter delay-timeratioleft delay-timeratioright delay-levelcenter 
   delay-levelleft delay-levelright delay-feedback delay-sendreverb delay-level delay-selected masterbar-recall-register 
   index-icon bassoon edited junk unknown ;


: parse-sc ( -- head ) test "SC" get-chunk first
  { [ 4 7 bsread-string ]                       ! Creator 
    [ 4 7 bsread-string ]                       ! Type
    [ 4 7 bsread-string ]                       ! Ver
    [ 4 7 bsread-string ]                       ! Num
    [ 8 7 bsread-string ]                       ! Name
    [ 7 swap bsread ]                           ! Reverb Character
    [ 7 swap bsread ]                           ! Reverb Prelpf
    [ 7 swap bsread ]                           ! Reverb Time
    [ 7 swap bsread ]                           ! Reverb Delay
    [ 7 swap bsread ]                           ! Reverb Predelay
    [ 7 swap bsread ]                           ! Reverb Level
    [ 7 swap bsread ]                           ! Reverb Selected
    [ 7 swap bsread ]                           ! Chorus Prelpf
    [ 7 swap bsread ]                           ! Chorus Feedback
    [ 7 swap bsread ]                           ! Chorus Delay
    [ 7 swap bsread ]                           ! Chorus Rate
    [ 7 swap bsread ]                           ! Chorus Depth
    [ 7 swap bsread ]                           ! Chorus Sendrev
    [ 7 swap bsread ]                           ! Chorus Senddelay
    [ 7 swap bsread ]                           ! Chorus Level
    [ 7 swap bsread ]                           ! Chorus Selected
    [ 7 swap bsread ]                           ! Delay Prelpf
    [ 7 swap bsread ]                           ! Delay Time Center
    [ 7 swap bsread ]                           ! Delay Time Ratio Left
    [ 7 swap bsread ]                           ! Delay Time Ratio Right
    [ 7 swap bsread ]                           ! Delay Level Center
    [ 7 swap bsread ]                           ! Delay Level Left
    [ 7 swap bsread ]                           ! Delay Level Right
    [ 7 swap bsread ]                           ! Delay Feedback
    [ 7 swap bsread ]                           ! Delay Send Reverb
    [ 7 swap bsread ]                           ! Delay Level
    [ 7 swap bsread ]                           ! Delay Selected
    [ 7 swap bsread ]                           ! Master Bar Recall Register
    [ 7 swap bsread ]                           ! Index-Icon
    [ 7 swap bsread ]                           ! Bassoon
    [ 7 swap bsread ]                           ! Edited
    [ 15 swap bsread ]                          ! Dummy
    [ 57 7 bsread-string ]                      ! Unknown
  } cleave scData boa ;

TUPLE: orData custom-name patch-cc00 patch-cc32 patch-pc patch-1-cc00 patch-1-cc32 patch-1-pc patch-1-volume patch-1-octave
  dynamic-mode reg-edited vtw-preset-ref vtw-preset-edited junk ;

: parse-o_r ( -- head ) test "O_R" get-chunk 
  [ { [ 12 7 bsread-string ]
    [ 7 swap bsread ]
    [ 7 swap bsread ]
    [ 7 swap bsread ]
    [ 7 swap bsread ]
    [ 7 swap bsread ]
    [ 7 swap bsread ]
    [ 7 swap bsread ]
    [ 7 swap bsread ]
    [ 7 swap bsread ]
    [ 7 swap bsread ]
    [ 7 swap bsread ]
    [ 7 swap bsread ]
    [ 8 7 bsread-string ] } cleave orData boa ] map ;


  

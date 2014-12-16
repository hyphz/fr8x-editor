! Copyright (C) 2014 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel locals accessors math sequences math.bitwise bitstreams io.files io xml io.encodings.binary xml.traversal strings
  assocs math.parser combinators fry arrays io.encodings.ascii io.encodings.string fr8x-data-format-syntax ;
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
    


! Defines scData, read-scData

ROLAND-CHUNK-FORMAT: scData
    creator ascii 4 7
    type ascii 4 7
    ver ascii 4 7
    num ascii 4 7
    name ascii 4 7
    reverb-character integer 7
    reverb-prelpf integer 7
    reverb-time integer 7
    reverb-delay integer 7
    reverb-predelay integer 7
    reverb-level integer 7
    reverb-selected integer 7
    chorus-prelpf integer 7
    chorus-feedback integer 7
    chorus-delay integer 7
    chorus-rate integer 7
    chorus-depth integer 7
    chorus-sendrev integer 7
    chorus-senddelay integer 7
    chorus-level integer 7
    chorus-selected integer 7
    delay-prelpf integer 7
    delay-time-center integer 7
    delay-time-ratio-left integer 7
    delay-time-ratio-right integer 7
    delay-level-center integer 7
    delay-level-left integer 7
    delay-level-right integer 7
    delay-feedback integer 7
    delay-send-reverb integer 7
    delay-level integer 7
    delay-selected integer 7
    master-bar-recall integer 7
    index-icon integer 7
    bassoon integer 7
    edited integer 7
    dummy integer 15
    unknown intlist 57 7 ;

    
! Defines: trData, read-trData


ROLAND-CHUNK-FORMAT: trData
    register-name ascii 8 7 
    voice-timbre-cc00 intlist 10 7
    voice-timbre-cc32 intlist 10 7
    voice-timbre-pc intlist 10 7
    voice-on-off intlist 10 7
    voice-cassotto intlist 10 7
    voice-volume intlist 10 7
    orchestral-mode integer 7
    orchestral-tone-num integer 7
    musette-detune integer 7
    reverb-send integer 7
    chorus-send integer 7
    delay-send integer 7
    bellow-pitch-detune integer 7
    octave integer 7
    valve-noise-on-off integer 7
    valve-noise-volume integer 7
    valve-noise-cc00 integer 7
    valve-noise-cc32 integer 7
    valve-noise-pc integer 7
    link-bass integer 7
    link-orch-bass integer 7
    link-orch-chord-freebass integer 7
    aftertouch-pitch-down integer 7
    note-tx-filter integer 7
    note-on-velocity integer 7
    midi-octave integer 7
    midi-cc0 integer 12
    midi-cc32 integer 12
    midi-pc integer 12
    midi-aftertouch integer 12
    midi-volume integer 12
    midi-panpot integer 12
    midi-reverb integer 12
    midi-chorus integer 12
    edited integer 7
    dummy intlist 7 7 ;


! Defines orData, read-orData
ROLAND-CHUNK-FORMAT: orData
   custom-name ascii 12 7
   patch-cc00 integer 7
   patch-cc32 integer 7
   patch-pc integer 7
   patch-1-cc00 integer 7
   patch-1-cc32 integer 7
   patch-1-pc integer 7
   patch-1-volume integer 7
   patch-1-octave integer 7
   dynamic-mode integer 7
   reg-edited integer 7
   vtw-preset-ref integer 7
   vtw-preset-edited integer 7
   junk intlist 8 7 ;
  

ROLAND-CHUNK-FORMAT: orchBassData
    custom-name ascii 12 7
    patch-cc00 integer 7
    patch-cc32 integer 7
    patch-pc integer 7
    dynamic-mode integer 7
    reg-edited integer 7
    vtw-preset-ref integer 7
    vtw-preset-edited integer 7
    junk intlist 8 7 ;


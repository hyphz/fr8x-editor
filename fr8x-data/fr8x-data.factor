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
    first <msb0-bit-reader> ;

:: bsread-string ( bitreader count width -- string ) 
    count [ width bitreader bsread ] replicate ascii decode ;
    

TUPLE: scData creator type ver num name reverb-character ;


: parse-sc ( -- head ) test "SC" get-chunk
  { [ 4 7 bsread-string ]                       ! Creator 
    [ 4 7 bsread-string ]                       ! Type
    [ 4 7 bsread-string ]                       ! Ver
    [ 4 7 bsread-string ]                       ! Num
    [ 8 7 bsread-string ]                       ! Name
    [ 7 swap bsread ]                           ! Reverb Character
  } cleave scData boa ;



  

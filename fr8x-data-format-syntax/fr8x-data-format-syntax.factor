! Copyright (C) 2014 Mark Green.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays byte-arrays classes.parser classes.tuple
combinators fry grouping io.encodings.ascii io.encodings.string
kernel lexer locals make math math.bits parser sequences words ;
IN: fr8x-data-format-syntax

RENAME: read bitstreams => bsread

: packbits ( bitseq value width -- bitseq )
    <bits> reverse append ;

: packlist ( bitseq list width -- bitseq )
    swapd '[ _ packbits ] reduce ;

: packstring ( bitseq string width -- bitseq )
    [ ascii encode ] dip packlist ;

: padbitseq ( bitseq -- bitseq )
    dup length 8 mod
    [ 8 swap - f <repetition> append ] unless-zero ;

: dumpbitseq ( bitseq -- ints )
    padbitseq 8 group [ reverse bits>number ] map >byte-array ;

! Huge thanks to John Benediktsson for the metaprogramming code below

: bsread-list ( bitreader count width -- list )
    rot '[ _ _ bsread ] replicate ;

: bsread-string ( bitreader count width -- string )
    bsread-list ascii decode ;

SYNTAX: ROLAND-CHUNK-FORMAT:
      scan-token
      [ "unpack-" prepend create-word-in ]
      [ "pack-" prepend create-word-in ]
      [ create-class-in ] tri
      [
          [ scan-token dup ";" = ] [
              scan-token {
                  { "ascii" [ scan-number scan-number
                              [ '[ _ _ bsread-string ] ]
                              [ '[ _ packstring ] ] bi
                            ] }
                  { "integer" [ scan-number
                              [ '[ _ swap bsread ] ]
                              [ '[ _ packbits ] ] bi
                            ] }
                  { "intlist" [ scan-number scan-number
                              [ '[ _ _ bsread-list ] ]
                              [ '[ _ packlist ] ] bi
                            ] }
              } case 3array ,
          ] until drop
      ] { } make
      [ tuple swap [ first ] map define-tuple-class ]
      [
          [ third ] map swap drop '[
            tuple-slots _ [ curry ] 2map { } swap
            [ call( oldbits -- newbits ) ] each
            dumpbitseq
          ] ( tuple -- bits ) define-declared
      ]
      [
          [ second ] map swap '[ _ cleave _ boa ]
          ( bitreader -- object ) define-declared
      ] 2tri ;

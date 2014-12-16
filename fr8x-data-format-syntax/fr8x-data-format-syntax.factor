! Copyright (C) 2014 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: lexer sequences parser classes.parser kernel fry bitstreams locals io.encodings.ascii io.encodings.string combinators
   arrays make assocs classes.tuple words ;
IN: fr8x-data-format-syntax

RENAME: read bitstreams => bsread 
    
! Huge thanks to John Benediktsson for the metaprogramming code below


:: bsread-list ( bitreader count width -- list ) 
    count [ width bitreader bsread ] replicate ;

: bsread-string ( bitreader count width -- string ) bsread-list ascii decode ;


SYNTAX: ROLAND-CHUNK-FORMAT:
      scan-token [ "read-" prepend create-in ] [ create-class-in ] bi
      [
          [ scan-token dup ";" = ] [
              scan-token {
                  { "ascii" [ scan-number scan-number '[ _ _ bsread-string ] ] }
                  { "integer" [ scan-number '[ _ swap bsread ] ] }
                  { "intlist" [ scan-number scan-number '[ _ _ bsread-list ] ] }
              } case 2array ,
          ] until drop
      ] { } make
      [ tuple swap keys define-tuple-class ]
      [
          values swap '[ _ cleave _ boa ]
          ( bitreader -- object ) define-declared
      ] 2bi ;

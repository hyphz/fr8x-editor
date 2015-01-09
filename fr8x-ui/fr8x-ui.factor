! Copyright (C) 2014 Mark Green and contributors.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs fry kernel locals make math math.parser
models multiline prettyprint sequences system ui ui.gadgets
ui.gadgets.book-extras ui.gadgets.borders ui.gadgets.buttons
ui.gadgets.editors ui.gadgets.grids ui.gadgets.labels
ui.gadgets.menus ui.gadgets.tracks namespaces fr8x-data 
models.arrow models.arrow.smart combinators combinators.short-circuit 
io strings io.encodings.utf8 io.files splitting colors.constants 
ui.pens.solid ui.gadgets.glass ;
IN: fr8x-ui
FROM: models => change-model ;

TUPLE: partmodel < model master extractor updater ;

: partmodel-fetch ( partmodel -- ) 
    dup [ master>> value>> ] [ extractor>> ] bi call( master -- part ) swap set-model ;

: new-partmodel ( master extractor updater class -- partmodel ) 
    f swap new-model swap >>updater swap >>extractor [ add-dependency ] [ swap >>master ] 2bi ; 

M: partmodel model-changed nip partmodel-fetch ;

M: partmodel model-activated partmodel-fetch ;

M: partmodel update-model
    dup master>> locked?>> [ "Warning: partmodel failing to update master" . drop ] [
        dup [ master>> value>> ] [ value>> ] [ updater>> ] tri call( mastervalue newslavevalue -- ) 
        master>> [ [ update-model ] [ notify-connections ] bi ] with-locked-model 
    ] if ; 

: <partmodel> ( master extractor updater -- partmodel ) partmodel new-partmodel ; 

: <nthmodel> ( master index -- partmodel ) 
    [ '[ _ swap nth ] ] [ '[ _ rot set-nth ] ] bi <partmodel> ;


SYMBOL: midireednames
SYMBOL: risky
SYMBOL: midireedindex

: risky? ( -- ? ) 
    risky get-global value>> ;

: placeholder ( -- gadget )
    vertical <track> "Lorem ipsum.." <label> f track-add ;

: voice-name ( num -- name ) {
    { 0 "16'" }
    { 1 "8'" }
    { 2 "8'-" }
    { 3 "8'+" }
    { 4 "4'" }
    { 5 "5-1/3'" }
    { 6 "2-2/3'" }
    { 7 "Unknown Extra Reed 1" }
    { 8 "Unknown Extra Reed 2" } } at* drop ;

: bool>bin ( bool -- bin ) 1 0 ? ;
: bin>bool ( bin -- bool ) 1 = ;

     
: raw-voice-name ( num -- name ) number>string "Voice " prepend ;

: midipatch>reed ( midipatch -- reedindex reeddata ) 
    midireednames get-global swap '[ first _ swap member? ] find ;

: reed-in-right-place? ( reedslot midipatch reeddata -- ? )
    first index = ;

: midipatch>reedindex-strict ( reedslot midipatch -- reedindex )
    dup midipatch>reed swap [ reed-in-right-place? ] keep swap 
    [ drop -1 ] unless ;


: treble-grid-line ( model voice -- gadgetseq ) 
    [ { 
        [ risky? [ raw-voice-name ] [ voice-name ] if <label> , drop ] 
        [ [ '[ voice-timbre-cc00>> _ swap nth number>string ] ] [ '[ string>number swap voice-timbre-cc00>> _ swap set-nth ] ] bi <partmodel> <model-field> , ]
        [ drop drop <editor> , ]
        [ drop drop <editor> , ]
        [ [ '[ voice-on-off>> _ swap nth bin>bool ] ] [ '[ bool>bin swap voice-on-off>> _ swap set-nth ] ] bi <partmodel> "" <checkbox> , ]
        [ [ '[ voice-cassotto>> _ swap nth bin>bool ] ] [ '[ bool>bin swap voice-cassotto>> _ swap set-nth ] ] bi <partmodel> "" <checkbox> , ]
        [ drop drop <editor> , ]
      } 2cleave 
    ] { } make ; 



: <blabel> ( label -- gadget ) <label> { 2 2 } <border> ;

: reed-editor ( regselector datamodel -- gadget )
    [ nth ] <smart-arrow>
    [
         [
            "Reed" <blabel> ,
            "CC00" <blabel> ,
            "CC32" <blabel> ,
            "PC" <blabel> ,
            "Enable" <blabel> ,
            "Cassotto" <blabel> ,
            "Volume" <blabel> ,
        ] { } make ,
        risky? 9 7 ?  [ '[ _ treble-grid-line , ] keep ] each-integer drop  
    ] { } make <grid> ;

: register-select ( button register -- ) swap model>> set-model ;

: register-buttons ( -- gadget )
    horizontal <track> 
    1 <model> >>model
    risky? 16 14 ? [
        [ 1 + number>string ] [ '[ _ register-select ] ] bi <border-button> 
        over model>> >>model  
        f track-add
    ] each-integer ;

: show-drop-menu ( button assoc quot -- )
    [ vertical <track> ] 2dip
    '[ swap [ swap parent>> hide-glass @ ] curry <roll-button> f track-add ] assoc-each
    COLOR: white <solid> >>interior
    { 4 4 } <border> 
    COLOR: white <solid> >>interior
    COLOR: black <solid> >>boundary 
    show-menu ; inline

: <drop-button> ( value assoc quot -- gadget )
    [ [ at ] keep ] dip '[ _ _ show-drop-menu ] <roll-button> ;

:: treble-editor ( model -- gadgets ) 
    vertical <track>
    register-buttons [ f track-add ] [ model>> ] bi                     
    model [ "TR" get-chunk ] <arrow> reed-editor f track-add
    0 midireednames get-global [ length iota ] [ values ] bi zip [ . ] <drop-button> f track-add ;

: editor-layout ( model -- gadget )
    [ [ treble-editor , ] keep ] { } make <book*> { 5 5 } <border> swap >>model ;


: readln-skipcomments ( -- line )
    f [ dup { [ string? not ] [ first CHAR: # = not ] } 1|| ] [ drop readln ] do until ; 


: parse-midivoice ( str -- tuple )
    " " split [ string>number ] map ;


: parse-midireed ( name -- reeddata ) 
    { } swap suffix
    { } 8 [ readln-skipcomments parse-midivoice suffix ] times 
    prefix ;

: make-reed-index ( reeds -- reedindex )
   [ length iota ] [ values ] bi zip
   { -1 "(Displaced reed)" } suffix
   { -2 "(Non-reed voice)" } suffix 
   { -3 "(Unknown MIDI patch)" } suffix ;

    
: parse-midi-reed-data ( -- reeddata )  
    [ readln-skipcomments dup ] [ parse-midireed ] produce nip ;

: load-midi-reed-data ( -- reeddata ) 
    "vocab:fr8x-data/midireeds.txt" utf8 [ parse-midi-reed-data ] with-file-reader ;

: disc-agree ( button -- )
    close-window 
    load-midi-reed-data dup midireednames set-global
    make-reed-index midireedindex set-global
    load-test-file <model> editor-layout "FR8x Set Editor" open-window ;

: disc-disagree ( button -- )
    close-window 1 exit ;

STRING: warning-text
Warning: This open source software is provided 'as-is' without
guarantee of any kind. This editor is not endorsed or authorised
by Roland or any associated company. Offline editing of set
files is not supported by Roland. This software and generated
sets may damage your computer and/or your V-Accordion. You use
this software and generated sets entirely at your own risk.
;

: warning-window ( -- gadget )
    f <model> risky set-global 
    vertical <track>
    warning-text <label> f track-add
    risky get-global "Enable experimental (even riskier) editing" <checkbox> { 0 10 } <border> f track-add
    "I agree. Start the editor." [ disc-agree ] <border-button> { 0 10 } <border> f track-add
    "I don't agree. Exit." [ disc-disagree ] <border-button> { 0 10 } <border> f track-add 
    { 5 5 } <border> ;

MAIN-WINDOW: main { { title "Warning!" } }
    warning-window >>gadgets ;

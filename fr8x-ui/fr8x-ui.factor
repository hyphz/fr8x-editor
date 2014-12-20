! Copyright (C) 2014 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: ui ui.gadgets.editors locals sequences ui.gadgets.menus assocs math math.parser fry system accessors kernel ui.gadgets ui.gadgets.grids ui.gadgets.borders ui.gadgets.buttons ui.gadgets.tracks ui.gadgets.labels ui.gadgets.book-extras make ;
IN: fr8x-ui


: placeholder ( -- gadget ) vertical <track> "Lorem ipsum.." <label> f track-add ;

: treble-grid-line ( string -- gadgetseq ) 
    [ <label> , <editor> , <editor> , <editor> , 0 <model> "" <checkbox> , 0 <model> "" <checkbox> , <editor> , ] { } make ;

: <blabel> ( label -- gadget ) <label> { 2 2 } <border> ;

: reed-editor ( -- gadget ) [
     [ "Reed" <blabel> , "CC00" <blabel> , "CC32" <blabel> , "PC" <blabel> , "Enable" <blabel> , "Cassotto" <blabel> , "Volume" <blabel> , ] { } make ,
     "Bassoon" treble-grid-line , 
     ] { } make <grid> ;

: register-select ( register -- ) drop ;


: register-buttons ( -- gadget ) 
    horizontal <track>
    15 [ [ 1 + number>string ] [ '[ _ register-select ] ] bi <border-button> f track-add ] each-integer ;


:: show-drop-menu ( button assoc quot -- ) assoc quot . . vertical <track> 
    [ button swap [ first ] [ second ] bi quot curry <roll-button> f track-add ] assoc each show-menu ; inline


: <drop-button> ( value assoc quot -- gadget ) 
    [ drop at* drop ] 2keep '[ _ _ show-drop-menu ] <roll-button> ;


: treble-editor ( -- gadgets )
    vertical <track>
    register-buttons f track-add
    reed-editor f track-add 
    0 { { 0 "Test" } { 1 "Moose" } } [ . ] <drop-button> f track-add ;





: editor-layout ( -- gadget ) [ treble-editor , ] { } make <book*> { 5 5 } <border> ;


: disc-agree ( button -- ) close-window editor-layout "FR8x Set Editor" open-window ;

: disc-disagree ( button -- ) close-window 1 exit ;


: warning-window ( -- gadget ) 
    vertical <track>
    "Warning: This open source software is provided 'as-is' without guarantee
of any kind. This editor is not endorsed or authorised by Roland
or any associated company. Offline editing of set files is not
supported by Roland. This software and generated sets may damage
your computer and/or your V-Accordion. You use this software and 
generated sets entirely at your own risk." <label>
    f track-add 
    "I agree. Let's do this." [ disc-agree ] <border-button> { 0 10 } <border> f track-add
    "Scary. Get me out of here." [ disc-disagree ] <border-button> { 0 10 } <border> f track-add 
    { 5 5 } <border> ;



MAIN-WINDOW: main { { title "Warning!" } }
    warning-window >>gadgets ;


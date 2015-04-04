! Copyright (C) 2014 Mark Green and contributors.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs fry kernel locals make math math.parser
models multiline prettyprint sequences system namespaces fr8x-data 
combinators combinators.short-circuit io strings io.encodings.utf8 
io.files splitting colors.constants gtk gtk.ffi alien.strings io.encodings.utf8 
gobject.ffi ;

IN: fr8x-ui-gtk

: s>gs ( string -- gstring ) utf8 string>alien ;




SYMBOL: midireednames
SYMBOL: risky
SYMBOL: midireedindex

: risky? ( -- ? ) 
    risky get-global value>> ;

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

! : midipatch>reedindex-strict ( reedslot midipatch -- reedindex )
!    dup midipatch>reed swap [ reed-in-right-place? ] keep swap 
!    [ drop -1 ] unless ;



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


STRING: warning-text
Warning: This open source software is provided 'as-is' without
guarantee of any kind. This editor is not endorsed or authorised
by Roland or any associated company. Offline editing of set
files is not supported by Roland. This software and generated
sets may damage your computer and/or your V-Accordion. You use
this software and generated sets entirely at your own risk.
;

: register-selector ( -- gadget ) 
  gtk_hbutton_box_new dup
  16 [ 1 + number>string s>gs gtk_button_new_with_label f f 2 gtk_box_pack_start dup ] each-integer
  drop ;


: editor-window ( -- gadget ) 
   GTK_WINDOW_TOPLEVEL gtk_window_new
   dup "FR8X Set Editor" s>gs gtk_window_set_title
   dup 300 200 gtk_window_set_default_size
   dup GTK_WIN_POS_CENTER gtk_window_set_position
   dup gtk_notebook_new
     dup f 2 gtk_vbox_new
       dup register-selector f f 2 gtk_box_pack_start
     "Accordion" s>gs gtk_label_new gtk_notebook_append_page drop
   dup "destroy" s>gs [ 2drop gtk_main_quit ] GtkObject:destroy f g_signal_connect drop  
   gtk_container_add ;
   

: start-editor ( -- )
    load-midi-reed-data dup midireednames set-global
    make-reed-index midireedindex set-global 
    editor-window gtk_widget_show_all ;

: warning-window ( -- gadget )
    GTK_WINDOW_TOPLEVEL gtk_window_new
    dup "Warning!" s>gs gtk_window_set_title
    dup 300 200 gtk_window_set_default_size
    dup GTK_WIN_POS_CENTER gtk_window_set_position
    dup f gtk_window_set_deletable
    dup f 2 gtk_vbox_new
      dup warning-text s>gs gtk_label_new f f 0 gtk_box_pack_start
      dup "Enable experimental (even riskier) editing" s>gs gtk_check_button_new_with_label f f 2 gtk_box_pack_start
      dup "I agree. Start the editor." s>gs gtk_button_new_with_label 
        dup "clicked" s>gs [ drop gtk_widget_get_toplevel gtk_widget_destroy start-editor ] GtkButton:clicked f g_signal_connect drop
      f f 2 gtk_box_pack_start
      dup "I don't agree. Exit." s>gs gtk_button_new_with_label 
        dup "clicked" s>gs [ drop gtk_widget_get_toplevel gtk_widget_destroy gtk_main_quit ] GtkButton:clicked f g_signal_connect drop  
      f f 2 gtk_box_pack_start
    gtk_container_add ;



: main ( -- )
   f f gtk_init
   warning-window gtk_widget_show_all 
   gtk_main ;

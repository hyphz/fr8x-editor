USING: kernel strings math byte-arrays accessors xml.data fr8x-data tools.test locals sequences bitstreams 
  io.encodings.binary io.files ;
IN: fr8x-data.tests 



! Checks that packing and unpacking a chunk leaves it unchanged
:: chunk-symmetry-test ( name unpacker packer -- ? )
    test-file-name binary [ parse-header load-chunks ] with-file-reader
    name get-chunk first 
    dup <msb0-bit-reader> 
    unpacker call packer call = ; inline


! Checks that decoding and encoding a file leaves it unchanged
: file-symmetry-test ( -- ? )
    load-test-file "symtest.st8" save-set-file
    test-file-name binary file-contents "symtest.st8" binary file-contents = ;


{ t } [ file-symmetry-test ] unit-test

{ t } [ "TR" [ unpack-trData ] [ pack-trData ] chunk-symmetry-test ] unit-test 
{ t } [ "SC" [ unpack-scData ] [ pack-scData ] chunk-symmetry-test ] unit-test 
{ t } [ "O_R" [ unpack-orData ] [ pack-orData ] chunk-symmetry-test ] unit-test 
{ t } [ "OB_R" [ unpack-obrData ] [ pack-obrData ] chunk-symmetry-test ] unit-test 
{ t } [ "OBC_R" [ unpack-obcrfData ] [ pack-obcrfData ] chunk-symmetry-test ] unit-test 
{ t } [ "OFB_R" [ unpack-obcrfData ] [ pack-obcrfData ] chunk-symmetry-test ] unit-test 
{ t } [ "BR" [ unpack-brData ] [ pack-brData ] chunk-symmetry-test ] unit-test 
{ t } [ "BCR" [ unpack-bcrData ] [ pack-bcrData ] chunk-symmetry-test ] unit-test 


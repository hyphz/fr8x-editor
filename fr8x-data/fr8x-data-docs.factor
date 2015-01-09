USING: help.markup help.syntax kernel strings math byte-arrays accessors xml.data sequences vectors assocs ;
IN: fr8x-data



HELP: read-header
{ $values { "bin" byte-array } }
{ $description "Reads from the current input stream until the first occurence of character 0x8d, which will read the XML preamble part of a .SET file." } ;

HELP: chop-junk
{ $values { "bin" byte-array } { "slice" slice } }
{ $description "Slices out everything before the first < in the input byte-array. This is used to remove the preliminary binary data before the XML preamble. Note that although this binary data has no documented significance, the accordion will not load any file where these bytes do not match." } ;

HELP: get-chunk-tags
{ $values { "head" xml } { "vector" vector } }
{ $description "Creates a vector of all elements immediately below the document editor in the input XML document, which in the FR-8X preamble corresponds to all of the data chunks." } ;

HELP: get-int-attr
{ $values { "attrs" assoc } { "name" string } { "int" integer } }
{ $description "Takes the named attribute from the passed associative array and converts to a number. Throws a loading-error if the attribute is missing. This is used for extracting the numeric value attributes from the XML elements in the preamble." } ;


HELP: parse-chunk-tag
{ $values { "tag" tag } { "chunkspec" chunkinfo } }
{ $description "Takes a tag structure representing a chunk tag from the premable and converts it into a chunkinfo object holding data on that chunk." } ;

HELP: parse-chunk-tags
{ $values { "vector" vector } { "chunks" vector } }
{ $description "Converts a vector of chunk tags as returned by get-chunk-tags into a vector of chunkinfo objects." } ;

HELP: parse-header
{ $values { "chunks" vector } }
{ $description "Reads the header from a set file, via the active input stream, and returns a vector of chunkinfo objects holding details on the data blocks in the file." } ;

HELP: load-chunk
{ $values { "chunkinfo" chunkinfo } { "offset" integer } { "chunkdata" assoc } }
{ $description "Reads the raw data of a chunk from a set file, via the active input stream, and returns a single assoc entry linking the chunk's name with its data. The data is in the form of a vector where each member is one record from the chunk, as a raw byte-array. Offset must be the number of bytes from the start of the set file from which position values should be counted." } ;

HELP: load-chunks
{ $values { "chunkinfos" vector } { "chunkdatas" assoc } }
{ $description "Reads the raw data of all chunks listed in the input vector from a set file, via the active input stream. The stream must be positioned at the end of the pre-amble, as it is after read-header." } ;

HELP: decode-known-chunks
{ $values { "chunks" assoc } }
{ $description "Modifies the assoc entries for all chunks for which the format is known and defined, changing them from vectors of raw data byte-arrays to vectors of appropriate tuple types."  } ;

HELP: encode-known-chunks
{ $values { "chunks" assoc } }
{ $description "Modifies the assoc entries for all chunks for which the format is known and defined, changing them from vectors of decoded data tuples back to raw data byte-arrays."  } ;

HELP: parse-set-file
{ $values { "data" assoc } }
{ $description "Reads a set file from the active input stream and returns an assoc of all chunks in the file, with those for which formats are defined decoded into tuple types." } ;

HELP: load-set-file
{ $values { "fn" string } { "data" assoc } }
{ $description "Reads the named set file and returns an assoc of all chunks in the file, with those for which formats are defined decoded into appropriate tuple types, and those for which formats are undefined left as raw data." } ;

HELP: get-chunk
{ $values { "alist" assoc } { "id" string } { "chunk" vector } }
{ $description "Reads the item with the appropriate id from the assoc and gives a 'missing chunk' exception if it is not found." } ;

HELP: write-chunks
{ $values { "chunks" assoc } }
{ $description "Encodes all chunks in the passed assoc down to raw data and writes them to the standard input stream." } ;

HELP: save-set-file
{ $values { "data" assoc } { "fn" string } }
{ $description "Copies the standard preamble to the named file, then encodes all chunks in the passed assoc down to raw data and writes them to the file. Provided the assoc contains all necessary chunks in the correct order, this should produce a set file acceptable to the accordion." } ;

HELP: load-test-file
{ $values { "head" assoc } }
{ $description "Designed for console and testing use. Loads the test file named in the fr8x-data source file using load-set-file." } ;



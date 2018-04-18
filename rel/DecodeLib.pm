#--------------------------------------------------------------------------------------------------------------------------
# the decoder package
#---------------------------------------------------------------------------------------------------------------------------

package DecodeLib;

my $VERSION = "1.0.0";

require 5.00503;
use strict 'refs';
use strict 'vars';
use strict 'subs';

use Exporter;
use IO::File;

use vars qw(@ISA @EXPORT $scriptName );

@ISA = qw(Exporter);

@EXPORT      = qw($scriptName
                  readTagName
                  readStringData
                  readBinData
                  fixTagList
                  printIQData
                  remove1stBinTag
                  remove1stStringTag);       # Symbols to autoexport (:DEFAULT tag)

BEGIN
{
$scriptName = "";
}

# Subroutine to read the first tag name from the input tag list
sub readTagName {

    my ($tagList) = @_;
    $tagList =~ m/\{(.+?)\:/;

    return $1;

}

# Read the string data for the norma tag
sub readStringData {

    my ($tagList, $tagName) = @_;
    $tagList =~ m/\{$tagName\:(.+?)\}/;

    return $1;
}

# Read bin data for the tag with length embeded
sub readBinData {

    my ($tagList, $tagName, $tagDataLength) = @_;
    my $tagData = substr $tagList, length($tagName) + 3, $tagDataLength;

    return $tagData;
}

# Remove the fisrt string tag from the tag list proveded
sub remove1stStringTag {

    my ($tagList, $tagName) = @_;
    $tagList =~ m/\{$tagName\:(.+?\}+?)(.+)/s;
    return $2;
}

# Remove the fisrt binary tag from the tag list proveded
sub remove1stBinTag {

    my ($tagList, $tagName, $tagDataLength) = @_;
    my $tagLength = $tagDataLength + length($tagName) + 4;
    my $tagListLength = length($tagList);
    my $newTagList = substr $tagList, $tagLength, $tagListLength-$tagLength;

    return $newTagList;
}

# 1) Remove everything from the next charcter of last "}" to the end of the scalar
# 2) Remove every bytes from the begining of the scalar to the first "{"
sub fixTagList {
    my ($tagList) = @_;

    # Clean the header of the tag list
    $tagList =~ m/(^[^\{]*)/;
    my $falseHeader = $1;
    if (defined $falseHeader) {
       $tagList = substr $tagList, length($falseHeader), length($tagList)-length($falseHeader);

    }
    # Clean the tailer of the tag list
    $tagList =~ m/.+\}([^\}]*)$/s;
    my $falseTailer = $1;
    if (defined $falseTailer) {

       $tagList = substr $tagList, 0, length($tagList)-length($falseTailer);
    }

    return $tagList;
}

# Parse and print the waveform IQ data to the output file
sub printIQData {
    my ($outFileH, $IQData) = @_;
    my @IQDataArray = unpack 's*', pack 'S*', unpack 'v*', $IQData;
    my $IQNumber = @IQDataArray;
    for (my $i=0; $i<$IQNumber; $i=$i+2) {
        my $formattedString = sprintf "%6s,%6s", ($IQDataArray[$i],$IQDataArray[$i+1]);
        print $outFileH  "$formattedString\n";
    }
}

1;                            # this should be your last line

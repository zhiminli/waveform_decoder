#!/usr/bin/perl -w

use strict;
use IO::File;
use DecodeLib;

my ($inFile, $outFile) = @ARGV;

if (not defined ($inFile)) {
	printf(" Please provide full-path input waveform file!\n");
        exit(1);
}

if (not defined ($outFile)) {
       $outFile=$inFile."."."out";
       printf (" Output file is not provided, set to $outFile\n");
}

my $inFileH; 
my $outFileH;

printf("Input file is $inFile \n");
printf("Output file is $outFile \n");

if ( ! open(INFILEH, "< $inFile") ) {
        printf("Open file $inFile failed!\n");
        exit(2);
}
binmode(INFILEH);
$inFileH=\*INFILEH;

# Read the content of the input file into a scalar
my $inFileContent = do { local $/; <$inFileH> };

$inFileContent = fixTagList($inFileContent);

close(INFILEH);

if ( ! open(OUTFILEH, ">> $outFile") ) {
        printf("Open file $outFile failed!\n");
        exit(3);
}
binmode(OUTFILEH);
$outFileH=\*OUTFILEH;

my $tagData = undef;
my $tagName = undef;

while (defined $inFileContent) {

    # Read the 1st tag name from the tag list
    $tagName = readTagName($inFileContent);
    printf("{$tagName:");
    if ($tagName =~ /(.+)-(.+)/) {
        my $tagDataLength = $2-1; # Real length  
        if ($tagName =~ m/EMPTYTAG/) {
           printf("SKIP empty tag}\n");
           print $outFileH "$tagName: SKIPPED\n"
        }
        else {
             $tagData = readBinData($inFileContent, $tagName, $tagDataLength);
             printf("}\n");
             print $outFileH "$tagName:\n";
             printIQData($outFileH, $tagData);
        }

        $inFileContent = remove1stBinTag($inFileContent, $tagName, $tagDataLength);
        my $newTagListLength = length($inFileContent);
        if ($newTagListLength == 0) { $inFileContent = undef; }
    }
    else {
        $tagData = readStringData($inFileContent, $tagName);
        printf("$tagData}\n");
        $inFileContent = remove1stStringTag($inFileContent, $tagName);

        print $outFileH "{$tagName:$tagData}\n";
    }

}

close(OUTFILEH);

exit(0);
